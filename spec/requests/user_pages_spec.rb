require 'rails_helper'
require_relative '../support/utilities.rb'
require_relative '../support/factories.rb'

describe "User Pages" do
  subject { page }

  shared_examples_for "user pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_title(full_title(page_title)) }
  end

  describe "Profile page" do
    let (:user) { FactoryGirl.create(:user) }
    let (:heading) { user.name }
    let (:page_title) { user.name }
    before { visit user_path(user) }

    it_should_behave_like "user pages"
  end

  describe "SignUp Page" do
    before { visit signup_path }
    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }

        it { should have_error_message('error') }
        it { should have_title(full_title('Sign Up')) }
      end
    end

    describe "with valid information" do
      before { valid_fill_in }

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: "user@example.com") }

        it { should have_link('Sign out') }
        it { should have_success_message('Welcome') }
        it { should have_title(full_title(user.name)) }
      end
    end

    let (:heading) { 'Sign Up' }
    let (:page_title) { 'Sign Up' }

    it_should_behave_like "user pages"
  end
end
