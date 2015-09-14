include ApplicationHelper

def example_user
  User.new(name: "Example User", email: "user@example.com",
    password: "foobar", password_confirmation: "foobar")
end

def valid_signin(user)
  fill_in "Email", with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
end

def valid_fill_in
  fill_in "Name",         with: "Example User"
  fill_in "Email",        with: "user@example.com"
  fill_in "Password",     with: "foobar"
  fill_in "Confirmation", with: "foobar"
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-danger', text: message)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-success', text: message)
  end
end

def duplicate_user(user)
  user_with_same_email = user.dup
  user_with_same_email.email = user.email.upcase
  user_with_same_email.save
end

def save_with_options(user, options = {})
  options.each { |key, value| user[key] = value }
  user.save
end

def invalid_addresses
  %w[user@foo,com user_at_foo.org example@foo.
    foo@bar_baz.com foo@bar+baz.com foo@bar..com]
end

def valid_adresses
  %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
end
