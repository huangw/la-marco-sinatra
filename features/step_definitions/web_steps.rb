# encoding: utf-8
require 'fileutils'

Given(/^pending$/) { pending }

Given(/I am running a local test/) do
  pending unless Capybara.app_host.match(/\/\/localhost/)
end

Given(/^I visit to "(.*)"$/) do |path|
  visit path
end

Then(/^debug$/) { debugger }

Then(/^take a screen shot as "(.*?)"$/) do |filename|
  FileUtils.mkdir 'doc/screenshots' unless File.directory?('doc/screenshots')
  sleep 1 if ENV['DRIVER'] == 'chrome'
  save_screenshot("doc/screenshots/#{filename}.png", full: true)
  embed("./screenshots/#{filename}.png", 'image/png', "SCREENSHOT for #{filename}")
end

When(/^(?:|I )fill in "([^\"]*)" with "([^\"]*)"$/)  do |field, value|
  fill_in(field, with: value)
end

When(/^I select "([^\"]*)" from "([^\"]*)"$/) do |value, dropdown|
  select(value, from: dropdown)
end

Then(/^I should see the text "([^"]*)"$/) do |text|
  expect(page).to have_content(text)
end

Then(/^I should see all of the texts:?$/) do |table|
  table.raw.each do |text|
    step "I should see the text \"#{text[0]}\""
  end
end

Then(/^I should not see the text "([^"]*)"$/) do |text|
  expect(page).to_not have_content(text)
end

Then(/^I should see the image "([^"]*)"$/) do |image_name|
  expect(page).to have_xpath("//img[contains(@src, \"#{image_name}\")]")
end

Then(/^I should see all of the images:?$/) do |table|
  table.raw.each do |text|
    step "I should see the image \"#{text[0]}\""
  end
end

Then(/^I attach the file "([^"]*)" to form field "([^"]*)"$/) do |filename, field_name|
  attach_file(field_name, ENV['APP_ROOT'] + "/examples/#{filename}")
end

Then(/^I should see the HTML5 audio source "([^"]*)"$/) do |audio_name|
  expect(page).to have_xpath("//audio[contains(@src, \"#{audio_name}\")] | //audio/source[contains(@src, \"#{audio_name}\")]")
end

Then(/^I should see all of the HTML5 audio sources:?$/) do |table|
  table.raw.each do |text|
    step "I should see the HTML5 audio source \"#{text[0]}\""
  end
end

Then(/^I should see the HTML5 video source "([^"]*)"$/) do |video_name|
  page.should have_xpath("//video[contains(@src, \"#{video_name}\")] | //video/source[contains(@src, \"#{video_name}\")]")
end

Then(/^I should see all of the HTML5 video sources:$/) do |table|
  table.raw.each do |text|
    step "I should see the HTML5 video source \"#{text[0]}\""
  end
end

Then(/^I should see an? link that points to "([^"]*)"$/) do |href_destination|
  page.should have_xpath("//a[@href='#{href_destination}']")
end

Then(/^I should see an? "([^"]*)" tag around the text "([^"]*)"$/) do |tag_name, text|
  page.should have_xpath("//#{tag_name}[text()=\"#{text}\"]")
end

Then(/^I should see an? "([^"]*)" with "([^"]*)" of "([^"]*)"$/) do |tag_name, attribute_name, attribute_value|
  page.should have_xpath("//#{tag_name}[@#{attribute_name}=\"#{attribute_value}\"]")
end

When(/^(?:|I )follow "([^\"]*)"$/) do |link|
  click_link(link)
end

When(/^(?:|I )press "([^\"]*)"$/) do |button|
  click_button(button)
end

When(/^I wait (\d+) seconds?$/) do |length_of_pause|
  sleep(length_of_pause.to_i)
end

When(/^I accept the confirmation dialog box$/) do
  page.driver.browser.switch_to.alert.accept
end

Then(/^I should on a page with title "(.+)"/) do |title|
  page.title.should eq(title)
end

Then(/^I should get a (\d+) response$/) do |status|
  page.status_code.to_i.should eq(status.to_i)
end

# extra steps
Then(/^show me the page(?: body)?$/) do
  puts page.body
end

Then(/^show me the cookies$/) do
  p all_cookies
end

Then(/^show me the cookie "(.*)"$/) do |key|
  p cookie(key.to_s)
end

Then(/^I should receive a cookie "([^"]*)"$/) do |key, _attr, _value|
  cookie(key.to_s).should_not be_nil
end

Then(/^I should receive a cookie "([^"]*)" with "([^"]*)" set to "([^"]*)"$/) do |key, attr, value|
  cookie(key.to_s).should_not be_nil
  cookie(key.to_s)[attr.to_sym].should eq(value)
end

Then(/^I should receive a cookie "([^"]*)" with "([^"]*)" set$/) do |key, attr|
  cookie(key.to_s).should_not be_nil
  cookie(key.to_s)[attr.to_sym].should_not be_nil
end

Then(/^I should receive a cookie "([^"]*)" without "([^"]*)"$/) do |key, attr|
  cookie(key.to_s).should_not be_nil
  cookie(key.to_s)[attr.to_sym].should be_nil
end

Then(/^I checked "(.*)"$/) do |chkbox_id|
  find(:css, '#' + chkbox_id).set(true)
end
