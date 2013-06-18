require 'spec_helper'

describe "UniquenessValidator" do

  before(:each) do
    @solr_field = "title_t"
    @validator = UniquenessValidator.new({:attributes => {}, :solr_name => @solr_field})
    @record = stub(pid:"avalon:1")
    @record.stub("errors").and_return([])
  end

  it "should raise an exception if solr_name option is missing" do
     validator = UniquenessValidator.new({attributes: {}})
     expect{validator.validate_each(@record, "title", "new_title")}.to raise_error ArgumentError
  end

  it "should not return errors when field is unique" do
    relation = stub()
    relation.stub("first").and_return(nil)
    @record.class.should_receive("where").once.with(@solr_field => "new_title").and_return(relation)
    @record.should_not_receive('errors')  
    @validator.validate_each(@record, "title", "new_title")
  end

  it "should not return errors when field is unique but record is the same" do
    doc = stub(pid: "avalon:1")
    relation = stub()
    relation.stub("first").and_return(doc)
    @record.class.should_receive("where").once.with(@solr_field => "new_title").and_return(relation)
    @record.should_not_receive('errors')
    @validator.validate_each(@record, "title", "new_title")
  end

  it "should return erros when field is not unique" do
    doc = stub(pid: "avalon:2")
    relation = stub()
    relation.stub("first").and_return(doc)
    @record.class.should_receive("where").once.with(@solr_field => "old_title").and_return(relation)
    @record.errors.should_receive('add')
    @validator.validate_each(@record, "title", "old_title")
  end  
end
