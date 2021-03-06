require 'rails_helper'

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

    describe 'submitting a DELETE request to the signed_in admin' do
      let(:admin) { FactoryGirl.create(:admin) }
      before { sign_in(admin, no_capybara: true) }

      specify { expect { delete :destroy, id: admin }.not_to change(User, :count) }
    end

    describe 'for signed-in users' do
      before { sign_in(user, no_capybara: true) }

      describe 'visiting the SignUp page' do
        before { get :new, id: user }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe 'submitting a POST request to the Users#create action' do
        before { post :create, id: user }
        specify { expect(response).to redirect_to(root_url) }
      end
    end

    describe 'for non-signed-in users' do

      describe 'visiting the Edit page' do
        before { get :edit, id: user }
        specify { expect(response).to redirect_to(signin_url) }
      end

      describe 'submitting a PATCH request to the Users#update action' do
        before { patch :update, id: user }
        specify { expect(response).to redirect_to(signin_url) }
      end

      describe 'submitting a DELETE request to the Users#delete action' do
        before { delete :destroy, id: user }
        specify { expect(response).to redirect_to(signin_url)}
      end

      describe 'visiting the Users page' do
        before { get :index }
        specify { expect(response).to redirect_to(signin_url) }
      end

      describe 'visiting following page' do
        before { get :following, id: user }
        specify { expect(response).to redirect_to(signin_url) }
      end

      describe 'visiting followers page' do
        before { get :followers, id: user }
        specify { expect(response).to redirect_to(signin_url) }
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
