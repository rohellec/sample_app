require "rails_helper"

describe UserMailer do
  describe "account_activation" do
    before(:all) do
      @user = FactoryGirl.create(:user)
      @user.activation_token = User.new_token
    end
    after(:all) { User.delete_all }
    let(:mail) { UserMailer.account_activation(@user) }

    it "renders the headers" do
      expect(mail.subject).to eq("Account activation")
      expect(mail.to).to eq([@user.email])
      expect(mail.from).to eq(["noreply@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(@user.name)
      expect(mail.body.encoded).to match(@user.activation_token)
      expect(mail.body.encoded).to match(CGI::escape(@user.email))
    end
  end

  describe "password_reset" do
    before(:all) do
      @user = FactoryGirl.create(:user)
      @user.reset_token = User.new_token
    end
    after(:all) { User.delete_all }
    let(:mail) { UserMailer.password_reset(@user) }

    it "renders the headers" do
      expect(mail.subject).to eq("Password reset")
      expect(mail.to).to eq([@user.email])
      expect(mail.from).to eq(["noreply@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(@user.reset_token)
      expect(mail.body.encoded).to match(CGI::escape(@user.email))
    end
  end
end
