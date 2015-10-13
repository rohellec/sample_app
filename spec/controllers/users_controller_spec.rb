require 'rails_helper'
require_relative '../support/utilities.rb'
require_relative '../support/factories.rb'

describe UsersController do

  describe 'authorization' do
    let(:user) { FactoryGirl.create(:user) }

    describe 'submitting a PATCH request with admin param to the Users#update action' do
      before do
        sign_in user, no_capybara: true
        patch :update, id: user, user: { admin: true, name: user.name, email: user.email,
                                         password: "foobar", password_confirmation: "foobar" }
      end

      specify { expect(user.reload).not_to be_admin }
    end

    describe 'submitting a DELETE request to the Users#destroy action' do
      let(:nonadmin) { FactoryGirl.create(:user) }
      before do
        sign_in(nonadmin, no_capybara: true)
        delete :destroy, id: user.id
      end

      specify { expect(response).to redirect_to(root_url) }
    end

    describe 'for non-signed-in users' do

      describe 'visiting the Edit page' do
        before { get :edit, id: user.id }
        specify { expect(response).to redirect_to(signin_path) }
      end

      describe 'submitting a PATCH request to the Users#update action' do
        before { patch :update, id: user.id }
        specify { expect(response).to redirect_to(signin_path) }
      end

      describe 'visiting the Users page' do
        before { get :index }
        specify { expect(response).to redirect_to(signin_path) }
      end
    end

    describe 'as wrong user' do
      let(:wrong_user) { FactoryGirl.create(:user, email: 'wrong@example.com') }
      before { sign_in(user, no_capybara: true) }

      describe 'submitting a GET request to the Users#edit action' do
        before { get :edit, id: wrong_user.id }
        specify { expect(response.body).not_to match(full_title('Edit user')) }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe 'submitting a PATCH request to the Users#update action' do
        before { patch :update, id: wrong_user.id }
        specify { expect(response).to redirect_to(root_url) }
      end
    end
  end
end
