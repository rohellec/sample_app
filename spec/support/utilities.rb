include ApplicationHelper

def example_user
  User.new(name: "Example User", email: "user@example.com",
    password: "foobar", password_confirmation: "foobar")
end

def sign_in(user, options = {})
  if options[:no_capybara]
    session[:user_id] = user.id
  else
    visit signin_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Sign in"
  end
end

def valid_fill_in(user, options = {})
  fill_in "Name",         with: (options[:name]  ? options[:name]  : user.name)
  fill_in "Email",        with: (options[:email] ? options[:email] : user.email)
  fill_in "Password",     with: user.password
  fill_in "Confirmation", with: user.password
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
