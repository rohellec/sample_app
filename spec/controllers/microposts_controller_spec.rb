require 'rails_helper'

describe MicropostsController do
  let(:user) { FactoryGirl.create(:user) }

  describe "submitting a POST request to Micropost#create action" do
    it "should redirect when not logged in" do
      expect { post :create }.not_to change(Micropost, :count)
      post :create
      expect(response).to redirect_to signin_url
    end
  end

  describe "submitting a DELETE request to Microposts#destroy action" do
    before { user.microposts.create!(content: "Example") }
    let(:micropost)  { user.microposts.first }
    let(:wrong_user) { FactoryGirl.create(:user) }

    it "should redirect when not logged in" do
      expect { delete :destroy, id: micropost.id }.not_to change(Micropost, :count)
      delete :destroy, id: micropost.id
      expect(response).to redirect_to signin_url
    end

    it "should redirect when log in as wrong user" do
      sign_in(wrong_user, no_capybara: true)
      expect { delete :destroy, id: micropost.id }.not_to change(Micropost, :count)
      delete :destroy, id: micropost.id
      expect(response).to redirect_to root_url
    end
  end
end
