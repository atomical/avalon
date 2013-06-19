FactoryGirl.define do
  
  factory :unit do
    sequence(:name) {|n| "Unit #{n}" }
    managers {|unit| unit.managers = [FactoryGirl.create(:manager)] }
  end
end