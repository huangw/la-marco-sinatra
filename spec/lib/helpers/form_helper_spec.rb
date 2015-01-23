require 'spec_helper'
require 'helpers/form_helper'

# request mock returns an fake path
class RequestMock
  def path
    'users/request'
  end
end

# mock object for form_for or field_for
class UserMock
  attr_accessor :name, :age, :sex, :hobby

  # def errors
  #   { age: 'age has error', messages: { age: 'age has error' } }
  # end
end

# mock the form helper
class FormMock
  attr_accessor :params
  include FormHelper

  def request
    RequestMock.new
  end

  def params
    @params ||= {}
  end
end

# rubocop:disable all
describe FormHelper do
  subject { FormMock.new }

  describe '#hash_to_html_attrs' do
    it 'render hash to attr list' do
      expect(subject.hash_to_html_attrs(ab: 'cd', ef: 'D'))
        .to eq('ab="cd" ef="D"')
    end

    it 'do not render key with nil value' do
      expect(subject.hash_to_html_attrs('ab' => 'cd', 'ef' => 'D', 'hijk' => nil))
        .to eq('ab="cd" ef="D"')
    end

    it 'render a key-only attribute for a special :empty value' do
      expect(subject.hash_to_html_attrs('ab' => 'cd', 'ef' => 'D', 'hijk' => :empty))
        .to eq('ab="cd" ef="D" hijk')
    end
  end

  describe '#single_tag' do
    it 'create tag with options' do
      expect(subject.single_tag(:some, { a: 'b' })).to eq("<some a=\"b\" />")
    end

    it 'create tag without options' do
      expect(subject.single_tag(:some)).to eq('<some />')
    end
  end

  describe '#tag' do
    it 'create a tag without options and contents' do
      expect(subject.tag(:some)).to eq('<some>')
    end

    it 'create a tag without options and contents' do
      expect(subject.tag(:some, 'name in')).to eq('<some>name in</some>')
    end

    it 'create a tag without options and contents' do
      expect(subject.tag(:some, 'age', { f: 'n' })).to eq('<some f="n">age</some>')
    end
  end

  describe '#form' do
    it 'returns form tag for simple call' do
      expect(subject.form).to eq(%q(<form action="/users/request" method="POST">))
    end

    it 'or a call for ":self"' do
      expect(subject.form(:self)).to eq(subject.form)
    end

    it 'can create get form' do
      expect(subject.form(:self, { method: :get }))
        .to eq(%q(<form action="/users/request" method="GET">))
    end

    it 'can mimic a delete form' do
      rslt = %q(<form action="/users/request" method="POST"><input type=) +
            %q("hidden" name="_method" id="_method" value="DELETE" />)
      expect(subject.form(:self, { method: :delete })).to eq(rslt)
    end

    it 'can rsltlicitly specify an action' do
      rslt = %q(<form action="/send-out" method="POST">)
      expect(subject.form('/send-out')).to eq(rslt)
    end

    it 'can create an upload form with data type' do
      rslt = %q(<form action="/users/request" method="POST" ) +
            %q(enctype="multipart/form-data">)
      expect(subject.form(:self, upload: true)).to eq(rslt)
    end

    it 'create a form for an object' do
      rslt = %q(<form action="/users/update" method="POST"></form>)
      expect(subject.form_for(UserMock.new, '/users/update') { |u| } ).to eq(rslt)
    end

    it 'create an upload for an object' do
      rslt = %q(<form action="/users/update" method="POST" ) +
             %q(enctype="multipart/form-data"></form>)
      expect(subject.form_for(UserMock.new, '/users/update', upload: true) { |u| } ).to eq(rslt)
    end
  end

  describe '#fieldset' do
    it 'create an open fieldset tag' do
      expect(subject.fieldset).to eq('<fieldset>')
    end

    it 'create an open fieldset with legend' do
      expect(subject.fieldset('user')).to eq('<fieldset><legend>user</legend>')
    end

    it 'create a fieldset for user' do
      rslt = '<fieldset><legend>user</legend></fieldset>'
      expect(subject.fieldset_for(UserMock.new, :user_mock, 'user') { |u| }).to eq(rslt)
    end
  end

  describe '#form_for' do
    it 'set default value from object' do
      user = UserMock.new
      user.name, user.age = 'John Simth', 18
      rslt = %q(<form action="/users/request" method="POST">) +
             %q(<input type="hidden" name="user_mock[name]" ) +
             %q(id="user_mock_name" value="John Simth" /></form>)
      expect(subject.form_for(user) { |f| f.hidden :name }).to eq(rslt)
    end

    it 'set default value from object' do
      subject.params = { user_mock: { name: 'Paul Adams' } }
      user = UserMock.new
      user.name, user.age = 'John Simth', 18
      rslt = %q(<form action="/users/request" method="POST">) +
             %q(<input type="hidden" name="user_mock[name]" ) +
             %q(id="user_mock_name" value="Paul Adams" /></form>)
      expect(subject.form_for(user) { |f| f.hidden :name }).to eq(rslt)
    end
  end

  describe '#fieldset_for' do
    it 'wrap a object inside an field set block' do
      user = UserMock.new
      user.name, user.age = 'Henry Simson', 18
      rslt = subject.form { subject.fieldset_for(user) { |f| f.hidden :name } }
      expect(rslt).to match('<fieldset><legend>UserMock</legend>')
      expect(rslt).to match('</fieldset>')
      expect(rslt).to match('Henry Simson')
    end

    it 'set params value to the field set' do
      subject.params = { user_mock: { name: 'Alfred Ford' } }
      user = UserMock.new
      user.name, user.age = 'Henry Simson', 18
      rslt = subject.form { subject.fieldset_for(user) { |f| f.hidden :name } }
      expect(rslt).to match('<fieldset><legend>UserMock</legend>')
      expect(rslt).to match('</fieldset>')
      expect(rslt).to_not match('Henry Simson')
      expect(rslt).to match('Alfred Ford')
    end
  end

  describe '#text' do
    it 'create an text input tag with default value from param' do
      subject.params = { login_id: 'logme@email.com' }
      rslt = '<input type="text" name="login_id" id="login_id" ' +
             'value="logme@email.com" />'
      expect(subject.text(:login_id)).to eq(rslt)
    end

    it 'create an text input tag within an form for block' do
      user = UserMock.new
      user.name, user.age = 'Henry Simson', 30
      rslt = subject.form_for(user) do |f|
        @out = ''
        @out << f.text(:name)
        @out << f.text(:age)
      end
      expect(rslt).to match('<input type="text" name="user_mock\[name\]"')
      expect(rslt).to match('value="Henry Simson"')
      expect(rslt).to match('<input type="text" name="user_mock\[age\]"')
      expect(rslt).to match('value="30"')
    end
  end

  describe '#label' do
    it 'create a label for a specific field' do
      expect(subject.label(:user_name, 'User Name'))
        .to eq('<label for="user_name">User Name</label>')
    end

    it 'create a label inside an form for' do
      user = UserMock.new
      user.name, user.age = 'Henry Simson', 30
      rslt = subject.form_for(user) do |f|
        @out = ''
        @out << f.label(:name, 'User Name')
        @out << f.text(:name)
      end
      expect(rslt).to match(/<label for="user_mock_name">User Name<\/label>/)
    end

    it 'create a label inside an field for' do
      user = UserMock.new
      user.name, user.age = 'Henry Simson', 30
      rslt = subject.form do
        subject.fieldset_for(user) do |f|
          @out = ''
          @out << f.label(:name, 'User Name')
          @out << f.text(:name)
        end
      end
      expect(rslt).to match(/<label for="user_mock_name">User Name<\/label>/)
    end
  end

  describe '#password' do
    it 'create an password input tag within an form for block' do
      user = UserMock.new
      user.name, user.age = 'Henry Simson', 30
      rslt = subject.form_for(user) do |f|
        @out = ''
        @out << f.text(:name)
        @out << f.password(:password)
      end
      expect(rslt).to match('<input type="text" name="user_mock\[name\]"')
      expect(rslt).to match('value="Henry Simson"')
      expect(rslt).to match('<input type="password" name="user_mock\[password\]"')
    end
  end

  describe '#submit' do
    it 'create a submit tag with default values' do
      rslt = '<input type="submit" name="submit" id="submit" value="Submit" />'
      expect(subject.submit).to eq(rslt)
    end

    it 'create a sumibt tag within a form_for block' do
      user = UserMock.new
      rslt = '<input type="submit" name="submit" id="submit" value="Submit" />'
      expect(subject.form_for(user) { |f| f.submit }).to match(rslt)
    end

    it 'create a submit tag with specific name and value' do
      u = UserMock.new
      rslt = '<input type="submit" name="submit" id="submit" value="Go" />'
      expect(subject.form_for(u) { |f| f.submit('Go') }).to match(rslt)
    end

    it 'create a submit tag with name value inside field set' do
      u = UserMock.new
      rslt = '<input type="submit" name="update" id="update" value="Go" />'
      expect(subject.form do
        subject.fieldset_for(u) do |f|
          f.submit('Go', name: 'update')
        end
      end).to match(rslt)
    end
  end

  describe '#button' do
    it 'create a button with default values' do
      rslt = '<input type="button" name="button" id="button" value="Button" />'
      expect(subject.button).to eq(rslt)
    end

    it 'create a button with name value inside field set' do
      u = UserMock.new
      rslt = '<input type="button" name="update" id="update" value="Setup" />'
      expect(subject.form do
        subject.fieldset_for(u) do |f|
          f.button('Setup', name: 'update')
        end
      end).to match(rslt)
    end
  end

  describe '#reset' do
    it 'create a Reset with name value inside field set' do
      u = UserMock.new
      rslt = '<input type="reset" name="update" id="update" value="Go" />'
      expect(subject.form do
        subject.fieldset_for(u) do |f|
          f.reset('Go', name: 'update')
        end
      end).to match(rslt)
    end
  end

  describe '#textarea' do
    it 'create a plain textarea' do
      rslt = '<textarea name="body" id="body" col="30">body string</textarea>'
      expect(subject.textarea('body', 'body string', { col: 30 })).to eq(rslt)
    end

    it 'create a textarea inside a form' do
      rslt = '<textarea name="user_mock\[body\]" id="user_mock_body"' +
             ' col="30">body string</textarea>'
      expect(subject.form_for(UserMock.new) do |f|
        f.textarea('body', 'body string', { col: 30 })
      end).to match(rslt)
    end
  end

  describe '#radio' do
    it 'create radio with one key' do
      rslt = '<input type="radio" name="sex" id="sex_f" value="f" /> ' +
             '<label for="sex_f">f</label>'
      expect(subject.radio(:sex, :f)).to eq(rslt)
    end

    it 'create radioes with array' do
      rslt = '<input type="radio" name="sex" id="sex_f" value="f" /> ' +
             '<label for="sex_f">f</label> ' +
             '<input type="radio" name="sex" id="sex_m" value="m" /> ' +
             '<label for="sex_m">m</label>'
      expect(subject.radio(:sex, [:f, 'm'])).to eq(rslt)
    end

    it 'create radioes with hash' do
      rslt = '<input type="radio" name="sex" id="sex_f" value="f" /> ' +
             '<label for="sex_f">Famale</label> ' +
             '<input type="radio" name="sex" id="sex_m" value="m" /> ' +
             '<label for="sex_m">Male</label>'
      expect(subject.radio(:sex, { f: :Famale, m: :Male })).to eq(rslt)
    end

    it 'set default values from params' do
      subject.params = { sex: :m }
      rslt = '<input type="radio" name="sex" id="sex_f" value="f" /> ' +
             '<label for="sex_f">Famale</label> ' +
             '<input type="radio" name="sex" id="sex_m" value="m" ' +
             'checked="checked" /> <label for="sex_m">Male</label>'
      expect(subject.radio(:sex, { f: :Famale, m: :Male })).to eq(rslt)
    end

    it 'create radio inside form for' do
      user = UserMock.new
      user.sex = :m
      rslt = subject.form_for(user) do |f|
        f.radio :sex, { f: :Famale, m: :Male }
      end
      inp = '<input type="radio" name="user_mock\[sex\]" '
      expect(rslt).to match(inp + 'id=\"user_mock_sex_f\" value="f" />')
      expect(rslt).to match(inp + 'id=\"user_mock_sex_m\" value="m" checked')
    end

    it 'create radio inside fieldset' do
      user = UserMock.new
      user.sex = :f
      rslt = subject.form do
        subject.fieldset_for(user) do |f|
          f.radio :sex, { f: :Famale, m: :Male }
        end
      end
      inp = '<input type="radio" name="user_mock\[sex\]" '
      expect(rslt).to match(inp + 'id=\"user_mock_sex_f\" value="f" checked')
      expect(rslt).to match(inp + 'id=\"user_mock_sex_m\" value="m" />')
    end

    it 'prefers params for form_for' do
      user = UserMock.new
      user.sex = :f
      subject.params = { user_mock: { sex: :m } }
      rslt = subject.form_for(user) do |f|
        f.radio :sex, { f: :Famale, m: :Male }
      end
      inp = '<input type="radio" name="user_mock\[sex\]" '
      expect(rslt).to match(inp + 'id=\"user_mock_sex_f\" value="f" />')
      expect(rslt).to match(inp + 'id=\"user_mock_sex_m\" value="m" checked')
    end
  end

  describe '#checkbox' do
    it 'create a single valued checkbox' do
      rslt = '<input type="checkbox" name="remember[]" id="remember_y" ' +
             'value="y" /> <label for="remember_y">Remember</label>'
      expect(subject.checkbox(:remember, { y: :Remember })).to eq(rslt)
    end

    it 'set default value from params for single valued checkbox' do
      subject.params = { remember: ['y'] }
      rslt = '<input type="checkbox" name="remember[]" id="remember_y" ' +
             'value="y" checked="checked" /> ' +
             '<label for="remember_y">Remember</label>'
      expect(subject.checkbox(:remember, { y: :Remember })).to eq(rslt)
    end

    it 'set default from object' do
      user = UserMock.new
      user.hobby = [:sleeping, :dancing]
      rslt = subject.form_for(user) do |f|

        @out = f.checkbox :hobby,
                          { sleeping: :Sleep, singing: :Sing, dancing: :Dance }
        @out << f.submit
      end
      inp = '<input type="checkbox" name="user_mock\[hobby\]\[\]"' +
            ' id="user_mock_hobby_'
      expect(rslt).to match(inp + 'sleeping" value="sleeping" checked')
      expect(rslt).to match(inp + 'singing" value="singing" />')
      expect(rslt).to match(inp + 'dancing" value="dancing" checked')
    end

    it 'prefers default values from params' do
      subject.params = { user_mock: { hobby: [:singing] } }
      user = UserMock.new
      user.hobby = [:sleeping, :dancing]
      rslt = subject.form_for(user) do |f|
        @out = f.checkbox :hobby,
                          { sleeping: :Sleep, singing: :Sing, dancing: :Dance }
        @out << f.submit
      end
      inp = '<input type="checkbox" name="user_mock\[hobby\]\[\]"' +
            ' id="user_mock_hobby_'
      expect(rslt).to match(inp + 'sleeping" value="sleeping" />')
      expect(rslt).to match(inp + 'singing" value="singing" checked')
      expect(rslt).to match(inp + 'dancing" value="dancing" />')
    end
  end

  describe '#select' do
    it 'create simple select box' do
      rslt = subject.select :year, [1988, 1989, 1990]
      expect(rslt).to match('<select name="year"')
      expect(rslt).to match('<option id="year_1988" value="1988">1988</option>')
    end

    it 'set default values from an object' do
      user = UserMock.new
      user.age = 30
      rslt = subject.form do
        subject.fieldset_for(user) do |f|
          @out = f.select :age, (1 .. 100).to_a
          @out << f.submit
        end
      end
      expect(rslt).to match('<select name="user_mock\[age\]"')
      expect(rslt).to match('<option id="user_mock_age_10" value="10">10</option>')
      seld = '<option id="user_mock_age_30" value="30"' +
             ' selected="selected">30</option>'
      expect(rslt).to match(seld)
    end
  end

  describe '#field_group' do
    it 'render a group/label/input set for an given object' do
      user = UserMock.new
      user.name = 'What Name'
      rslt = subject.form_for(user) do |f|
        @out = f.field_group(:name)
        @out << f.field_group(:age)
      end

      expect(rslt).to match('<form ')
      expect(rslt).to match('<div class="form-group">' +
                        '<label class="control-label" for="user_mock_name">')
      # expect(rslt).to match('<div class="form-group has-error">' +
      #                   '<label class="control-label" for="user_mock_age"')
      expect(rslt).to match('id="user_mock_name" class="form-control"' +
                            ' value="What Name"')
    end
  end
end
