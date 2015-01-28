# encoding: utf-8
require 'fileutils'

Given(/^我?打开\s*"(.*)"$/) do |path|
  visit path
end

Then(/^截图为"(.*?)"$/) do |filename|
  FileUtils.mkdir 'doc/screenshots' unless File.directory?('doc/screenshots')
  sleep 1 if ENV['DRIVER'] == 'chrome'
  save_screenshot("doc/screenshots/#{filename}.png", full: true)
  embed("./screenshots/#{filename}.png", 'image/png', "SCREENSHOT for #{filename}")
end

When(/^我?在"([^\"]*)"中输入"([^\"]*)"$/)  do |field, value|
  fill_in(field, with: value)
end

When(/^我?从"([^\"]*)"中选择"([^\"]*)"$/) do |dropdown, value|
  select(value, from: dropdown)
end

Then(/^选择框"(.*?)"的"(.*?)"被选中$/) do |selected, value|
  expect(page).to have_select(selected, selected: value)
end
Then(/^页面应包含\s*"([^"]*)"$/) do |text|
  expect(page).to have_content(text)
end

Then(/^页面应包含按钮"(.*?)"$/) do |text|
  expect(page).to have_button(text)
end

Then(/^页面应跳转到"(.*?)"$/) do |url|
  expect(current_path).to eq(url)
end

Then(/^页面应包含以下内容(?:：|:)?$/) do |table|
  table.raw.each do |text|
    step "I should see the text \"#{text[0]}\""
  end
end

Then(/^页面不应包含\s*"([^"]*)"$/) do |text|
  page.should_not have_content(text)
end

Then(/^页面应包含图片\s*"([^"]*)"$/) do |image_name|
  page.should have_xpath("//img[contains(@src, \"#{image_name}\")]")
end

Then(/^页面应包含下列图片(?:：|:)?$/) do |table|
  table.raw.each do |text|
    step "I should see the image \"#{text[0]}\""
  end
end

Then(/^我?上传文件"([^"]*)"到表单项"([^"]*)"$/) do |filename, field_name|
  attach_file(field_name, ENV['APP_ROOT'] + "/examples/#{filename}")
end

Then(/^页面应包含音频文件\s*"([^"]*)"$/) do |audio_name|
  page.should have_xpath("//audio[contains(@src, \"#{audio_name}\")] | //audio/source[contains(@src, \"#{audio_name}\")]")
end

Then(/^页面应包含下列音频文件(?:：|:)?$/) do |table|
  table.raw.each do |text|
    step "I should see the HTML5 audio source \"#{text[0]}\""
  end
end

Then(/^页面应包含视频文件\s*"([^"]*)"$/) do |video_name|
  page.should have_xpath("//video[contains(@src, \"#{video_name}\")] | //video/source[contains(@src, \"#{video_name}\")]")
end

Then(/^页面应包含下列视频文件(?:：|:)?$/) do |table|
  table.raw.each do |text|
    step "I should see the HTML5 video source \"#{text[0]}\""
  end
end

Then(/^页面应包含指向"([^"]*)"的链接$/) do |href_destination|
  page.should have_xpath("//a[@href='#{href_destination}']")
end

Then(/^页面应包含文字为"([^"]*)"的"([^"]*)"标签$/) do |text, tag_name|
  page.should have_xpath("//#{tag_name}[text()=\"#{text}\"]")
end

Then(/^页面应包含"([^"]*)"属性为"([^"]*)"的"([^"]*)"标签$/) do |attribute_name, attribute_value, tag_name|
  page.should have_xpath("//#{tag_name}[@#{attribute_name}=\"#{attribute_value}\"]")
end

When(/^我?点击"([^\"]*)"链接$/) do |link|
  if link =~ /^[.#].*$/
    find(link).click
  else
    click_link(link)
  end
end

When(/^我?点击"([^\"]*)"按钮$/) do |button|
  click_button(button)
end

Then(/^我选中\s*"(.*)"$/) do |chkbox_id|
  find(:css, '#' + chkbox_id).set(true)
end

When(/^我?等待(\d+)秒$/) do |length_of_pause|
  sleep(length_of_pause.to_i)
end

When(/^我点击确认$/) do
  page.driver.browser.switch_to.alert.accept
end

Then(/^页面标题应为\s*"(.+)"/) do |title|
  page.title.should eq(title)
end

Then(/^服务器应该返回状态码\s*(\d+)$/) do |status|
  page.status_code.to_i.should eq(status.to_i)
end

# extra steps
Then(/^输出HTML源码$/) do
  puts page.body
end

Then(/^输出cookie内容$/) do
  p all_cookies
end

Then(/^输出\s*"(.*)"\s*对应的cookie内容$/) do |key|
  p cookie(key.to_s)
end

Then(/^服务器应返回cookie\s*"([^"]*)"$/) do |key, _attr, _value|
  cookie(key.to_s).should_not be_nil
end

Then(/^服务器应返回cookie\s*"([^"]*)"，"([^"]*)"\s*的值应为\s*"([^"]*)"$/) do |key, attr, value|
  cookie(key.to_s).should_not be_nil
  cookie(key.to_s)[attr.to_sym].should eq(value)
end

Then(/^服务器应返回cookie\s*"([^"]*)"\s*应包含\s*"([^"]*)" set$/) do |key, attr|
  cookie(key.to_s).should_not be_nil
  cookie(key.to_s)[attr.to_sym].should_not be_nil
end

Then(/^服务器应返回cookie\s*"([^"]*)"\s*不应包含\s*"([^"]*)"$/) do |key, attr|
  cookie(key.to_s).should_not be_nil
  cookie(key.to_s)[attr.to_sym].should be_nil
end

Then(/^暂停"(.*?)"秒$/) do |num|
  sleep num.to_i
end
