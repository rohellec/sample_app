require 'rails_helper'

describe "Static pages" do

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_title(full_title(page_title)) }
  end

  describe "Home page" do
    before { visit root_path }
    let(:heading) { 'Sample App' }
    let(:page_title) { '' }

    it_should_behave_like "all static pages"
    it { should_not have_title("| Home") }

    describe "for signed in user" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        50.times { user.microposts.create!(content: Faker::Lorem.sentence(5)) }
        sign_in(user)
        visit root_path
      end

      it { should have_selector("div.pagination") }
      it { should have_selector("span.picture") }

      it "should list user's and following feed microposts" do
        10.times { user.follow(FactoryGirl.create(:user)) }
        user.following.each do |followed|
          followed.microposts.create!(content: Faker::Lorem.sentence(5))
        end
        user.feed.paginate(page: 1) do |micropost|
          expect(page).to have_selector("li#micropost-#{micropost.id}", text: micropost.content)
        end
      end
    end
  end

  describe "Help page" do
    before { visit help_path }
    let(:heading) { 'Help' }
    let(:page_title) { 'Help' }

    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }
    let(:heading) { 'About Us' }
    let(:page_title) { 'About Us' }

    it_should_behave_like "all static pages"
  end


  describe "Contact" do
    before { visit contact_path }
    let(:heading) { 'Contact' }
    let(:page_title) { 'Contact' }

    it_should_behave_like "all static pages"
  end

  it "should have the right links on the layout" do
    visit root_path
    click_link("About")
    expect(page).to have_title(full_title('About Us'))
    click_link("Help")
    expect(page).to have_title(full_title('Help'))
    click_link("Contact")
    expect(page).to have_title(full_title('Contact'))
    click_link("Home")
    click_link("Sign up now!")
    expect(page).to have_title(full_title('Sign Up'))
    click_link("sample app")
    expect(page).to have_title(full_title(''))
  end
end
