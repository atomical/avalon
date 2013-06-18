require 'spec_helper'


describe Avalon::ManagersAssociation do
  describe 'add manager' do
    let(:user){ FactoryGirl.create(:user)}
    let(:collection){ Collection.new }
    let(:association){ Avalon::ManagersAssociation::Proxy.new(collection) }

    context 'shovel operator' do
      it 'adds array with one element' do
        association << [user]
        association.count.should == 1
      end
      it 'adds array with many elements' do
        association <<  (1..3).map{ FactoryGirl.create(:user) }
        association.count.should == 3
      end
    end
  end
end