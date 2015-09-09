include ApplicationHelper

def valid_signin(user)
  fill_in "Email", with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-danger', text: message)
  end
end

def duplicate_user(user)
  user_with_same_email = user.dup
  user_with_same_email.email = user.email.upcase
  user_with_same_email.save
end
