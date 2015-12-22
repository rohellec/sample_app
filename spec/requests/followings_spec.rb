require 'rails_helper'

describe "Follow" do
  subject { page }

  let(:followed) { FactoryGirl.create(:user) }
  let(:follower) { FactoryGirl.create(:user) }

  describe "Followers page" do
    before do
      sign_in followed
      10.times { FactoryGirl.create(:user).follow(followed) }
      visit followers_user_path(followed)
    end

    it { should have_content(followed.followers.count) }
    it { should have_title("Followers") }
    it { should have_selector('h3', text: "Followers") }

    it "should list all user's followers" do
      expect(followed.followers).not_to be_empty
      followed.followers.each do |follower|
        expect(page).to have_link(follower.name, href: user_path(follower))
      end
    end
  end

  describe "Following page" do
    before do
      sign_in follower
      10.times { follower.follow(FactoryGirl.create(:user)) }
      visit following_user_path(follower)
    end

    it { should have_content(follower.following.count) }
    it { should have_title("Following") }
    it { should have_selector('h3', text: "Following") }

    it "should list all user's following" do
      expect(follower.following).not_to be_empty
      follower.following.each do |followed|
        expect(page).to have_link(followed.name, href: user_path(followed))
      end
    end
  end

  describe "follow/unfollow buttons" do
    before { sign_in follower }

    describe "following a user" do
      before { visit user_path(followed) }

      it "should increment the following user count" do
        expect { click_button "Follow" }.to change(follower.following, :count).by(1)
      end

      it "should increment the followers count for followed user" do
        expect { click_button "Follow" }.to change(followed.followers, :count).by(1)
      end

      describe "toggling the button" do
        before { click_button "Follow" }
        it { should have_xpath("//input[@value='Unfollow']") }
      end
    end

    describe "unfollowing a user" do
      before do
        follower.follow(followed)
        visit user_path(followed)
      end

      it "should decrement the following user count" do
        expect { click_button "Unfollow" }.to change(follower.following, :count).by(-1)
      end

      it "should decrement the followers count for followed user" do
        expect { click_button "Unfollow" }.to change(followed.followers, :count).by(-1)
      end

      describe "toggling the button" do
        before { click_button "Unfollow" }
        it { should have_xpath("//input[@value='Follow']") }
      end
    end
  end
end
