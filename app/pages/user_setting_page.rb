# [Controller] UserSettingPage
#   (app/pages/user_setting_page.rb)
# vim: foldlevel=1
# created at: 2015-11-26

# Web page controller for path to '/user/settings'
class UserSettingPage < WebController
  get '/' do
    rsp :index
  end

  Route << self
end
