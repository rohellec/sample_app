require 'rails_helper'

describe Micropost do
  let(:user) { FactoryGirl.create(:user) }
  before { @micropost = user.microposts.build(content: "Lorem ipsum", user_id: user.id) }

  subject { @micropost }

  it { should respond_to(:content) }
  it { should respond_to(:user) }
  it { should be_valid }

  describe "when content is empty" do
    before { @micropost.content = " " * 5 }
    it { should_not be_valid }
  end

  describe "when content is too large" do
    before { @micropost.content = "a" * 141 }
    it { should_not be_valid }
  end

  describe "when user_id is not present" do
    before { @micropost.user = nil }
    it { should_not be_valid }
  end
end
