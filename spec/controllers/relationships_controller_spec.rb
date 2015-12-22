require 'rails_helper'

describe RelationshipsController do
  let(:follower) { FactoryGirl.create(:user) }
  let(:followed) { FactoryGirl.create(:user) }

  describe "submitting a POST request to Relationships#create action" do
    it "should redirect when not logged in" do
      post :create, followed_id: followed.id
      expect(response).to redirect_to signin_url
    end
  end

  describe "submitting a DELETE request to Relationships#destroy action" do
    before { follower.follow(followed) }
    let(:relationship) { follower.active_relationships.first }

    it "should redirect when not logged in" do
      delete :destroy, id: relationship.id
      expect(response).to redirect_to signin_url
    end
  end

  describe "creating a relationship" do
    before { sign_in follower, no_capybara: true }

    describe "using a standard way" do
      it "should increment the Relationship count" do
        expect do
          post :create, followed_id: followed.id
        end.to change(Relationship, :count).by(1)
      end

      it "should redirect to followed user" do
        post :create, followed_id: followed.id
        expect(response).to redirect_to followed
      end
    end

    describe "with Ajax" do
      it "should increment the Relationship count" do
        expect do
          xhr :post, :create, followed_id: followed.id
        end.to change(Relationship, :count).by(1)
      end

      it "should respond with a success" do
        xhr :post, :create, followed_id: followed.id
        expect(response).to be_success
      end
    end
  end

  describe "destroying a relationship" do
    before do
      follower.follow(followed)
      sign_in follower, no_capybara: true
    end
    let(:relationship) { follower.active_relationships.find_by(followed_id: followed.id) }

    describe "using a standard way" do
      it "should decrement the Relationship count" do
        expect do
          delete :destroy, id: relationship.id
        end.to change(Relationship, :count).by(-1)
      end

      it "should redirect to followed user" do
        delete :destroy, id: relationship.id
        expect(response).to redirect_to followed
      end
    end

    describe "with Ajax" do

      it "should increment the Relationship count" do
        expect do
          xhr :delete, :destroy, id: relationship.id
        end.to change(Relationship, :count).by(-1)
      end

      it "should respond with a success" do
        xhr :delete, :destroy, id: relationship.id
        expect(response).to be_success
      end
    end
  end
end
