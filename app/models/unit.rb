require 'role_controls'

class Unit < ActiveFedora::Base
  include ActiveFedora::Associations
  include Avalon::ManagersAssociation
  has_many :collections, property: :is_member_of

  has_metadata name: 'descMetadata', type: ActiveFedora::SimpleDatastream do |sds|
    sds.field :name, :string
  end

  delegate :name, to: :descMetadata, unique: true

  validates :name, :uniqueness => { :solr_name => 'name_t'}, presence: true

  #Move this into a decorator?
  def created_at
    if new?
      #Note that this time changes until it has been persisted in Fedora
      create_date.to_datetime
    else
      @created_at ||= DateTime.parse(create_date) 
    end
  end

  def to_solr(solr_doc = Hash.new, opts = {})
    super(solr_doc, opts)
    map = Solrizer::FieldMapper::Default.new
    solr_doc[ map.solr_name(:name, :string, :searchable).to_sym ] = self.name
    solr_doc[ map.solr_name(:collection_count, :integer, :sortable).to_sym ] = self.collections.size
    solr_doc
  end
end
