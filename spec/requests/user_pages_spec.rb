require 'rails_helper'

describe "User Pages" do

  subject { page }

  shared_examples_for "logged in layout" do
    it { should have_link('Users',       href: users_path) }
    it { should have_link('Profile',     href: user_path(found_user)) }
    it { should have_link('Settings',    href: edit_user_path(found_user)) }
    it { should have_link('Sign out',    href: signout_path) }
    it { should_not have_link('Sign in', href: signin_path) }
  end

  describe "Profile page" do

    describe "trying to visit for not-activated user" do
      let(:user) { FactoryGirl.create(:user, activated: false) }
      before { visit user_path(user) }

      it { should have_title("Sample App") }
      it { should have_selector("h1", text: "Sample App") }
    end

    describe "for activated user" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        50.times { user.microposts.create!(content: Faker::Lorem.sentence(5)) }
        visit user_path(user)
      end

      it { should have_selector('h1', text: user.name) }
      it { should have_title(full_title(user.name)) }
      it { should have_selector('div.pagination') }

      it "should list each micropost" do
        user.microposts.paginate(page: 1) do |micropost|
          expect(page).to have_selector("li#micropost-#{micropost.id}", text: micropost.content)
        end
      end
    end
  end

  describe "SignUp Page" do
    before { visit signup_path }
    let(:submit) { "Create my account" }

    it { should have_selector("h1", text: "Sign Up") }
    it { should have_title(full_title("Sign Up")) }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }

        it { should have_error_message('error') }
        it { should have_title('Sign Up') }
      end
    end

    describe "with valid information" do
      let(:user) { new_user }
      before { fill_in_user_form(user) }

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after submission" do
        before do
          ActionMailer::Base.deliveries.clear
          click_button submit
        end

        let(:found_user) { User.find_by(email: user.email) }

        it "should not activate user" do
          expect(ActionMailer::Base.deliveries.size).to eq 1
          expect(found_user).not_to be_activated
        end

        it "should not allow to sign in" do
          sign_in(user)
          message = "Account not activated. Check your email for activation link."
          expect(page).to have_warning_message(message)
          expect(page).to have_title("Sample App")
        end

        describe "following activation link" do

          describe "with invalid activation token" do
            before { visit edit_account_activation_path("invalid token", email: found_user.email) }

            it { should have_title("Sample App") }
            it { should have_error_message("Invalid activation link") }
          end

          describe "with valid activation_token" do
            let(:activation_token) { last_email.to_s.match(/(?<=account_activations\/)[\-\w]+/) }

            describe "with wrong email" do
              before { visit edit_account_activation_path(activation_token, email: "wrong_email@example.com") }

              it { should have_title("Sample App") }
              it { should have_error_message("Invalid activation link") }
            end

            describe "with right email" do
              before { visit edit_account_activation_path(activation_token, email: found_user.email) }

              it { should have_title(found_user.name) }
              it { should have_success_message("Account activated!") }
              it_should_behave_like "logged in layout"
              specify { expect(found_user.reload).to be_activated }
            end
          end
        end
      end
    end
  end

  describe "Edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_selector("h1", text: "Update your profile") }
      it { should have_title(full_title("Edit user")) }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before do
        fill_in "Name", with: ""
        click_button "Save changes"
      end

      it { should have_error_message("error") }
      it { should have_title("Edit user") }
    end

    describe "with valid information" do
      let(:new_name)  { 'New Name' }
      let(:new_email) { 'new@example.com' }

      before do
        fill_in_user_form(user, name: new_name, email: new_email)
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
      before(:all) do
        10.times { FactoryGirl.create(:user, activated: false) }
        10.times { FactoryGirl.create(:user) }
      end
      after(:all)  { User.delete_all }

      it { should have_selector("div.pagination") }

      it "should list each user" do
        User.paginate(page: 1, per_page: 20).each do |user|
          expect(page).to     have_selector('li', text: user.name) if user.activated?
          expect(page).not_to have_selector('li', text: user.name) if !user.activated?
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
