require 'active_support/concern'

module Avalon
  module ManagersAssociation
    extend ActiveSupport::Concern

    included do

      # attr_accessor :managers

      def managers
        @managers ||= Avalon::ManagersAssociation::Proxy.new(self)
      end

      def managers=( managers )
        self.managers.clear
        self.managers << managers
      end

      def self.find_all_by_manager_id( id )
        where(:manager_ids_facet => id.to_s)
      end
    end

    module InstanceMethods

      def to_solr(solr_doc = Hash.new, opts = {})
        map = Solrizer::FieldMapper::Default.new
        solr_doc[ map.solr_name(:manager_ids, :string, :facetable) ] = self.managers.map(&:id)
        super(solr_doc)
      end
    end
  

    class Proxy
      instance_methods.each { |m| undef_method m unless m =~ /(^__|^send$|^object_id$)/ }

      def initialize( associated_class )
        @associated_class = associated_class
        ActiveFedora::Predicates.predicate_mappings["info:fedora/fedora-system:def/relations-external#"][:has_manager] = 'hasManager'
        raise ArgumentError, 'First argument must be an instance that inherits from ActiveFedora::Base' unless associated_class.class.superclass == ActiveFedora::Base
      end

      def << ( new_managers )
        if new_managers.class == Array        
          new_managers.each do |manager|
            add_manager(manager) unless manager.in?( managers )
          end
        else
          add_manager(new_managers)
        end
      end

      def delete( manager )
        @managers.delete(manager)
        @associated_class.remove_relationship(:has_manager, "info:fedora/#{manager.id}")
      end

      def clear
        @associated_class.clear_relationship :has_manager
        @managers = []
      end

      private

        def add_manager( manager )
          @associated_class.add_relationship(:has_manager,  RDF::Literal.new("info:fedora/#{manager.id}"))
          @managers << manager
        end

      protected

        def method_missing(name, *args, &block)
          managers.send(name, *args, &block)
        end

        def managers
          @managers ||= User.find(@associated_class.relationships(:has_manager).map{|m| m.to_s.delete('info:fedora/').to_i })
        end

    end
  end
end