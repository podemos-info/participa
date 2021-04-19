# features/step_definitions/home_page_steps.rb
Given(/^there's a post titled "(.*?)" with "(.*?)" content$/) do |title, content|
  @post = FactoryBot.create(:post, title: title, content: content)
end

When(/^I am on the homepage$/) do
  visit root_path
end

Then(/^I should see the "(.*?)" post$/) do |title|
  @post = Post.find_by_title(title)

  page.should have_content(@post.title)
  page.should have_content(@post.content)
end