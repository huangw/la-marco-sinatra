Feature: rack server works
  Get `hello world` message from the simplest route.

  Scenario: show '/simple' page
    Given I visit to "/simple"
    Then I should see the text "Hello, world!"
