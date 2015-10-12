require 'rails_helper'
require_relative '../support/factories.rb'

describe SessionsHelper do
  let(:user) { FactoryGirl.create(:user) }
  before { remember(user) }

  describe "current_user returns right user when session is nil" do
    specify { expect(current_user).to eq user }
    specify { expect(signed_in?).to be_truthy }
  end

  describe "current_user returns nil when remember_digest is wrong" do
    before { user.update_attribute(:remember_digest, User.digest(User.new_token)) }
    specify { expect(current_user).to be_nil }
  end

  describe "when user is remembered cookies should not be nil" do
    specify { expect(cookies[:remember_token]).not_to be_nil }
  end

  describe "when user is forgotten cookies should be nil" do
    before  { forget(user) }
    specify { expect(cookies[:remember_token]).to be_nil }
  end
end
