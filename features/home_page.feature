Feature: Home Page

  Scenario: Admin can change home page content
    Given I am signed in as an administrator
    And I am on the Website CMS page
    And I fill in "Home content" with "Welcome!"
    And I press "Update Website"
    When I am on the home page
    Then I should see "Welcome!"

  Scenario: Admin can change start page content
    Given I am signed in as an administrator
    And I am on the Website CMS page
    And I fill in "Start page content" with "What to do next..."
    And I press "Update Website"
    When I am on the start page
    Then I should see "What to do next..."
