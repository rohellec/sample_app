require 'rails_helper'
require_relative '../support/utilities.rb'

describe "User Pages" do
  subject { page }

  describe "SignUp Page" do
    before { visit signup_path }

    it { should have_content('Sign Up') }
    it { should have_title(full_title('Sign Up')) }
  end  
end
