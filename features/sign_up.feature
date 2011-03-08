Feature: Sign Up

  As an advertiser
  I want to sign up
  So that MySkiChalet will remember my details and adverts

  Scenario: Going to the sign up page
    Given I am on the sign in page
    When I follow "Sign Up"
    Then I should be on the sign up page

  Scenario: Sign up for a new account
    Given I am on the sign up page
    When I fill in "Name" with "Carol"
    And I fill in "Email" with "carol@myskichalet.co.uk"
    And I fill in "Password" with "secret"
    And I press "Sign Up"
    Then I should be on the advertiser home page
    And I have a new account set up

  Scenario: Password should be at least 5 characters long
    Given I am on the sign up page
    When I fill in "Name" with "Carol"
    And I fill in "Email" with "carol@myskichalet.co.uk"
    And I fill in "Password" with "1234"
    And I press "Sign Up"
    Then I should be on the users page
    And I should see "Password is too short (minimum is 5 characters)"

  Scenario: Email address should be unique
    Given I am on the sign up page
    When I fill in "Name" with "Bob"
    And I fill in "Email" with "bob@myskichalet.co.uk"
    And I fill in "Password" with "secret"
    And I press "Sign Up"
    Then I should be on the users page
    And I should see "Email has already been taken"
