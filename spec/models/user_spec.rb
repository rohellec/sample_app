require 'rails_helper'

describe User do

  before { @user = new_user }

  subject { @user }

  it { should respond_to(:name)  }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_digest) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:activation_token) }
  it { should respond_to(:activation_digest) }
  it { should respond_to(:reset_digest) }
  it { should respond_to(:reset_token) }
  it { should respond_to(:microposts) }

  it { should be_valid }
  it { should_not be_admin }

  describe "with admin rights" do
    before { @user.toggle!(:admin) }
    it { should be_admin }
  end

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

  describe "when password is blank" do
    before { @user.password = @user.password = " " * 6 }
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
    before { @user.save }
    specify { expect(@user.authenticated?(:remember, '')).to be_falsey }
  end

  describe "micropost associations" do
    before { @user.save }

    it "order should be most recent first" do
      5.times do
        micropost = FactoryGirl.create(:micropost, content: "Lorem Ipsum", user_id: @user.id)
        expect(micropost).to eq Micropost.first
      end
    end

    it "should destroy associated microposts" do
      5.times { FactoryGirl.create(:micropost, content: "Lorem Ipsum", user_id: @user.id) }
      microposts = @user.microposts.to_a
      @user.destroy
      expect(microposts).not_to be_empty
      microposts.each do |post|
        expect(Micropost.find_by(id: post.id)).to be_nil
      end
    end
  end
end
