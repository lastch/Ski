Feature: My Details

  As an advertiser
  I want to keep my details up to date
  So that I can be contacted and billed and so that I can see advertising
  features of interest to me

  Scenario: Register an interest in advertising properties for rent
    Given that I am signed in
    And I am not interested in advertising properties for rent
    When I go to the my details page
    And I check "interested in renting out properties"
    And I press "Save"
    And I go to the advertiser home page
    Then I should see "My Properties for Rent"
