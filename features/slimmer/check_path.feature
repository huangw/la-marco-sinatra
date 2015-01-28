Feature: Slim helper can find proper files to render
  Slim helper provide a `rsp` method that can find the template file from
  logical path.

  Scenario: mapping '/' to 'index'
    Given I visit to "/slim-test"
     Then I should see the text "/slimmer/check_paths/index"

  Scenario: convert 'xx-xx' maps to 'xx_xx'
    Given I visit to "/slim-test/any-page"
     Then I should see the text "/slimmer/check_paths/any_page"

  Scenario: render template with partial
    Given I visit to "/slim-test/specifies/gogogo"
     Then I should see the text "This is a special title for gogogo"
      And I should see the text "I am a partial form block for gogogo"

  Scenario: render template by locales
    Given I visit to "/slim-test/multi-tone?locale=en"
     Then I should see the text "English"
     When I visit to "/slim-test/multi-tone?locale=zh"
     Then I should see the text "中文中文"
