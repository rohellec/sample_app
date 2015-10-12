require 'rails_helper'
require_relative '../support/utilities.rb'
require_relative '../support/factories.rb'

describe 'Authentication' do
  subject { page }

  describe 'SignIn page' do
    before { visit signin_path }

    it { should have_selector('h1', text: 'Sign In') }
    it { should have_title(full_title('Sign In')) }
  end

  describe 'sign in' do
    before { visit signin_path }

    describe 'with invalid information' do
      before { click_button 'Sign in' }

      it { should have_title(full_title('Sign In')) }
      it { should have_error_message('Invalid') }

      describe "after visiting another page" do
        before { click_link 'Home' }
        it { should_not have_error_message('Invalid') }
      end
    end

    describe 'with valid information' do
      let(:user) { FactoryGirl.create(:user) }
      before { valid_signin(user) }

      it { should have_title(full_title(user.name)) }
      it { should have_link('Users',       href: users_path) }
      it { should have_link('Profile',     href: user_path(user)) }
      it { should have_link('Settings',    href: edit_user_path(user)) }
      it { should have_link('Sign out',    href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe 'followed by sign out' do
        before { click_link 'Sign out' }

        it { should have_title(full_title('')) }
        it { should have_link('Sign in', href: signin_path) }
        it { should_not have_link('Sign out', href: signout_path) }
        it { should_not have_link('Profile',  href: user_path(user)) }
        it { should_not have_link('Settings', href: edit_user_path(user)) }
        it { should_not have_link('Users', href: users_path) }

        describe 'and then signed out from another window' do
          before { delete signout_path }

          it { should have_title(full_title('')) }
          it { should have_link('Sign in', href: signin_path) }
          it { should_not have_link('Sign out', href: signout_path) }
          it { should_not have_link('Profile',  href: user_path(user)) }
          it { should_not have_link('Settings', href: edit_user_path(user)) }
          it { should_not have_link('Users', href: users_path) }
        end
      end
    end
  end

  describe 'authorization' do

    describe 'for non-signed-in users' do
      let(:user) { FactoryGirl.create(:user) }

      describe 'when attempting to visit a protected page' do
        before do
          visit edit_user_path(user)
          fill_in 'Email', with: user.email
          fill_in 'Password', with: user.password
          click_button 'Sign in'
        end

        describe 'after signing in' do
          it 'should render the desired protected page' do
            expect(page).to have_title(full_title('Edit user'))
          end
        end
      end
    end
  end
end
