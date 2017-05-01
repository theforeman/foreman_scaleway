FactoryGirl.modify do
  factory :compute_resource do
    trait :scaleway do
      provider 'Scaleway'
      user Foreman.uuid # alias for api_organization
      password Foreman.uuid # alias for api_token
      url 'par1' # alias for region
      after(:build) { |cr| cr.stubs(:set_organization) }
    end
  end
end
