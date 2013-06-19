FactoryGirl.define do
  factory :collection do
    sequence(:name) {|n| "Collection #{n}" }
    unit
    managers {|unit| unit.managers = [FactoryGirl.create(:manager)] }
  end
end