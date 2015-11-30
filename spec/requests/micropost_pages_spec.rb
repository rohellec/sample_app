require 'rails_helper'

describe "Micropost pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user, email: "other@example.com") }
  let(:content) { "This micropost really ties the room together" }
  before { sign_in(user) }

  describe "micropost creation" do
    before { visit root_path }

    describe "with invalid information" do

      describe "for content" do
        it "should not create a micropost" do
          expect { click_button "Post" }.not_to change(Micropost, :count)
        end

        describe "error messages" do
          before { click_button "Post" }
          it { should have_error_message("error") }
        end
      end

      describe "for picture" do
        before { fill_in "micropost_content", with: content }

        describe "when picture is too big" do
          before { attach_file("micropost_picture", File.join(Rails.root, "/spec/support/images/big_image.jpg")) }

          it "should not create a micropost" do
            expect { click_button "Post" }.not_to change(Micropost, :count)
          end

          describe "error messages" do
            before { click_button "Post" }
            it { should have_error_message("error") }
          end
        end

        describe "when file upload has incorrect format" do
          before { attach_file("micropost_picture", File.join(Rails.root, "/spec/support/images/sample_text")) }

          it "should not create a micropost" do
            expect { click_button "Post" }.not_to change(Micropost, :count)
          end

          describe "error messages" do
            before { click_button "Post" }
            it { should have_error_message("error") }
          end
        end
      end
    end

    describe "with valid information" do
      before do
        attach_file("micropost_picture", File.join(Rails.root, "/spec/support/images/rails.png"))
        fill_in "micropost_content", with: content
      end

      it "should create a post" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end

      describe "after clicking the submition button" do
        before { click_button "Post" }

        it { should have_success_message("created") }
        it { should have_selector("li", text: content) }
        specify { expect(user.microposts.first.picture?).to be_truthy }
      end
    end
  end

  describe "micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user) }
    let(:micropost) { user.microposts.first }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link "delete", match: :first }.to change(Micropost, :count).by(-1)
      end

      describe "after clicking the link" do
        before { click_link "delete", href: micropost_path(micropost) }

        it { should have_success_message("deleted") }
        it { should_not have_selector("li", text: micropost.content) }
      end
    end

    describe "as wrong user" do
      before do
        @micropost = other_user.microposts.create!(content: content)
        visit user_path(other_user)
      end

      it { should_not have_link("delete", href: micropost_path(@micropost)) }
    end
  end

  describe "micropost sidebar count" do
    before do
      10.times { user.microposts.create!(content: Faker::Lorem.sentence(5)) }
    end

    describe "for user with several microposts" do
      before { visit root_path }
      it { should have_selector("span", text: "#{user.microposts.count} microposts") }
    end

    describe "for user with 0 microposts" do
      before do
        sign_in(other_user)
        visit root_path
      end
      it { should have_selector("span", text: "0 microposts") }

      describe "after creating a new one" do
        before do
          other_user.microposts.create!(content: Faker::Lorem.sentence(5))
          visit root_path
        end
        it { should have_selector("span", text: "1 micropost") }
      end
    end
  end
end
