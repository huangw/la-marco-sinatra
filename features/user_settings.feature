Feature: walk through pages for '/user/settings' (UserSettingPage)
  Include the description here

  Scenario: show '/user/settings' page
    Given I visit to "/user/settings"
    Then I should see the text "用户设置"
