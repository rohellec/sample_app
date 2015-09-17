require 'rails_helper'
require_relative '../support/utilities.rb'

describe User do

  before { @user = example_user }

  subject { @user }

  it { should respond_to (:name)  }
  it { should respond_to (:email) }
  it { should respond_to (:password_digest) }
  it { should respond_to (:password) }
  it { should respond_to (:password_confirmation) }
  it { should respond_to (:remember_digest) }
  it { should respond_to (:remember_token) }

  it { should be_valid }

  describe "when name is not present" do
    before { @user.name = "" }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { @user.email = "" }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = 'a' * 51 }
    it { should_not be_valid }
  end

  describe "when email is too long" do
    before { @user.email = 'a' * 255  + '@example.com'}
    it { should_not be_valid }
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      invalid_addresses.each do |address|
        @user.email = address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      valid_adresses.each do |address|
        @user.email = address
        expect(@user).to be_valid
      end
    end
  end

  describe "email address in mixed case" do
    let(:mixed_case_email) { "Foo@eXamPle.CoM" }

    it "should be saved as lower-case" do
      save_with_options(@user, email: mixed_case_email)
      expect(@user.reload.email).to eq mixed_case_email.downcase
    end
  end

  describe "when email address is already taken" do
    before { duplicate_user(@user) }
    it { should_not be_valid }
  end

  describe "when password is not presented" do
    before { @user.password = @user.password_confirmation = "" }
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = 'a' * 5 }
    it { should_not be_valid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    describe "when return value is valid" do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe "when return value is invalid" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_falsey }
    end
  end

  describe "authenticated? method should return false for a user with nil digest" do
    specify { expect(@user.authenticated?('')).to be_falsey }
  end
end
