Feature: ensures the route mechanism works properly
  Route table is used by Rack::Builder mapping in config.ru.

  Scenario: '/' explicitly set to RootPage under /users
    Given I visit to "/"
    Then I should see the text "user root page"

  Scenario: '/admin' explicitly set to RootPage under /admin
    Given I visit to "/admin"
    Then I should see the text "This is the root of administration portal"

  Scenario: '/admin/users' automatically mapped to Admin::UserPage
    Given I visit to "/admin/users"
    Then I should see the text "This is where the administrator manages users"
    Given I visit to "/admin/users/someid"
    Then I should see the text "This page for user with some id"
