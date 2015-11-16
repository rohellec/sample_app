require 'rails_helper'

describe "Password reset:" do
  subject { page }
  before  { ActionMailer::Base.deliveries.clear }
  let(:user) { FactoryGirl.create(:user) }
  let(:root_title) { "Sample App" }

  shared_examples_for "root page" do
    it { should have_title(root_title) }
    it { should have_selector("h1", text: root_title) }
  end

  shared_examples_for "logged in layout" do
    it { should have_link('Users',       href: users_path) }
    it { should have_link('Profile',     href: user_path(found_user)) }
    it { should have_link('Settings',    href: edit_user_path(found_user)) }
    it { should have_link('Sign out',    href: signout_path) }
    it { should_not have_link('Sign in', href: signin_path) }
  end

  describe "Forgot password" do
    before { visit new_password_reset_path }

    describe "with invalid submission" do
      before { click_button "Submit" }
      it { should have_error_message("") }
    end

    describe "with valid submission" do
      before do
        fill_in "Email", with: user.email
        click_button "Submit"
      end

      it "should sent reset password email" do
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(user.reset_digest).not_to eq user.reload.reset_digest
        expect(page).to have_info_message("Email sent")
        expect(page).to have_title("Sample App")
      end

      describe "after following redirection link" do
        let(:found_user) { User.find_by(email: user.email) }
        let(:root_title) { "Sample App" }

        describe "with invalid reset token" do
          before { visit edit_password_reset_path("wrong token", email: found_user.email) }
          it_should_behave_like "root page"
        end

        describe "with valid reset token" do
          let(:reset_token) { last_email.to_s.match(/(?<=password_resets\/)[\-\w]+/) }

          describe "for not-activated user" do
            before do
              found_user.toggle!(:activated)
              visit edit_password_reset_path(reset_token, email: found_user.email)
            end

            it_should_behave_like "root page"
          end

          describe "with invalid email" do
            before { visit edit_password_reset_path(reset_token, email: "") }
            it_should_behave_like "root page"
          end

          describe "and with valid email" do

            describe "after token has expired" do
              before do
                found_user.update_attribute(:reset_sent_at, 3.hours.ago)
                visit edit_password_reset_path(reset_token, email: found_user.email )
              end

              it { should have_title("Forgot password") }
              it { should have_error_message("Password reset expired.")}
            end

            describe "before token has expired" do
              before { visit edit_password_reset_path(reset_token, email: found_user.email) }

              it { should have_title("Reset password") }
              it { should have_selector("h1", text: "Reset password") }

              describe "after 'Reset password' form submission" do

                describe "with empty password" do
                  before { click_button "Update password" }

                  it { should have_error_message("error") }
                  it { should have_title("Reset password") }
                end

                describe "with invalid password and confirmation" do
                  before do
                    fill_in "Password",     with: "foobar"
                    fill_in "Confirmation", with: "abcdef"
                    click_button "Update password"
                  end

                  it { should have_error_message("error") }
                  it { should have_title("Reset password") }
                end

                describe "with valid password and confirmation" do
                  before do
                    fill_in "Password",     with: "foobaz"
                    fill_in "Confirmation", with: "foobaz"
                    click_button "Update password"
                  end

                  it { should have_title(found_user.name) }
                  it { should have_success_message("Password has been reset.") }
                  it_should_behave_like "logged in layout"
                end
              end
            end
          end
        end
      end
    end
  end
end
