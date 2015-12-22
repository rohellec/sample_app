require 'rails_helper'

describe Relationship do
  let(:follower) { FactoryGirl.create(:user) }
  let(:followed) { FactoryGirl.create(:user) }
  let(:relationship) { follower.active_relationships.build(followed_id: followed.id) }

  subject { relationship }

  it { should be_valid }

  describe "follower methods" do
    it { should respond_to(:follower) }
    it { should respond_to(:followed) }
    specify { expect(relationship.follower).to eq follower }
    specify { expect(relationship.followed).to eq followed }
  end  

  describe "should require a follower_id" do
    before { relationship.follower = nil }
    it { should_not be_valid }
  end

  describe "should require a followed_id" do
    before { relationship.followed = nil }
    it { should_not be_valid }
  end
end
