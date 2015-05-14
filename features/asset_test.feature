Feature: Assets settings and assets helper
  Ensure js/css and img settings and helper works as expected

  Scenario: get asset settings from `settings.assets`
    Given I visit to "/asset/tests/settings/img_dir"
     Then I should see the text "app/assets/img"
