require 'spec_helper'
require 'cancan/matchers'

describe Unit do
  before(:each) do
    @manager = FactoryGirl.create(:content_provider)
    @collection = FactoryGirl.create(:collection, name: 'Herman B. Wells Collection')
    @unit = FactoryGirl.create(:unit, name: 'University archives', managers: [@manager], collections: [@collection])
    @collection.unit = @unit
  end

  describe 'abilities' do

    subject{ ability }
    let(:ability){ Ability.new(user) }
    let(:user){ @collection.unit.managers.first }

    context 'when unit manager' do
      it{ should be_able_to(:manage, @unit) }
    end
  end

  describe 'validations' do

    it {should validate_presence_of(:name)}
    it {should validate_uniqueness_of(:name)}

    it "should be titled" do
     @unit.name.should == "University archives"
    end

    it "should have created_at defined" do
     @unit.created_at.should == DateTime.parse(@unit.create_date)
    end

    it "should have one manager" do
     @unit.managers.should == [@manager]
    end

    it "should have one collection" do
     @unit.collections.should == [@collection]
    end

    it "should solrize important information" do
     map = Solrizer::FieldMapper::Default.new
     @unit.to_solr[ map.solr_name(:name, :string, :searchable).to_sym ].should == "University archives"
     @unit.to_solr[ map.solr_name(:collection_count, :integer, :sortable).to_sym ].should == 1
    end
  end
end
