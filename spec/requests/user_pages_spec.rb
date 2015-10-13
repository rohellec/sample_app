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
      let(:user) { example_user }
      before { valid_fill_in(user) }

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:found_user) { User.find_by(email: user.email) }

        it { should have_link('Sign out') }
        it { should have_success_message('Welcome') }
        it { should have_title(full_title(found_user.name)) }
      end
    end

    let (:heading) { 'Sign Up' }
    let (:page_title) { 'Sign Up' }

    it_should_behave_like "user pages"
  end

  describe "Edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      let(:heading) { "Update your profile" }
      let(:page_title) { "Edit user" }

      it_should_behave_like "user pages"
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }

      it { should have_error_message('error') }
    end

    describe "with valid information" do
      let(:new_name)  { 'New Name' }
      let(:new_email) { 'new@example.com' }

      before do
        valid_fill_in(user, name: new_name, email: new_email)
        click_button 'Save changes'
      end

      it { should have_title(full_title(new_name)) }
      it { should have_success_message('Profile updated') }
      it { should have_link('Sign out', href: signout_path) }
      specify { expect(user.reload.name).to  eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end
  end

  describe "index" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      sign_in user
      visit users_path
    end

    it { should have_title("All users") }
    it { should have_selector("h1", text: "All users") }

    describe "pagination" do
      before(:all) { 10.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it { should have_selector("div.pagination") }

      it "should list each user" do
        User.paginate(page: 1, per_page: 10).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    describe "delete links" do
      it { should_not have_link("delete") }

      describe "sign in as an admin" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link("delete", href: user_path(User.first)) }
        it { should_not have_link("delete", href: user_path(admin)) }
        it "should be able to delete another user" do
          expect { click_link "delete", match: :first }.to change(User, :count).by(-1)
        end
      end
    end
  end
end
