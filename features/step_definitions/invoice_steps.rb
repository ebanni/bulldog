Given(/^I am on the New Invoice page$/) do
  visit '/invoices/new'
end

Given(/^I select the customer (.*?)$/) do |customer|
  select customer,    from: 'invoice_customer_id'
end

Then(/^I should see a (.*?) button$/) do |btn|
  find_link(btn) || find_button(btn)
end

Given(/^I have created the (.*?) invoice$/) do |customer|
  steps %{
    Given I am on the New Invoice page
    And I select the customer #{customer}
    And I change the comment to "My business invoice"
    And I click button Create Invoice
  }
end

Given(/^I am on the invoices index page$/) do
  visit '/invoices/'
end

When(/^I change the (.*?) to "(.*?)"$/) do |field, value|
  fill_in "invoice_#{field}", with: value
end

Given(/^I am on the edit page for this invoice$/) do
  id = Invoice.last.id
  visit "/invoices/#{id}/edit"
end

Then(/^I should see (\d+) bills?$/) do |arg1|
  expect(all("table#bill_table tr").count - 2).to eq arg1
end

When(/^I check one bill and click Update Invoice$/) do
  within(:xpath, "//table/tr[2]") do
    check('bill_ids_')
  end
  click_button('Update Invoice')
end

Then(/^I should see (\d+) invoices$/) do |arg1|
  expect(all("table#invoice_table tr").count - 2).to eq arg1
end

Then(/^There is a search field for comment$/) do
  page.has_selector?("#invoices_search")
end

When(/^I type "(.*?)" in the search field and press enter$/) do |search|
  fill_in 'search', with: search
  click_button('Refresh')
end

Given /^I have the following invoices$/ do |table|
  #puts table.raw
  table.raw.each do |row|
      number   = row[0]
      customer = Customer.find_or_create_by(name: row[1], account_id: @account.id)
      comment  = row[2]
      date     = row[3]
      total    = row[4]
      invoice  = FactoryGirl.create(:invoice,
                        account_id: @account.id,     # assumes user with an account already called
                        number: number,
                        customer_id: customer.id,
                        date: date, 
                        comment: comment,
                        total: total)
  end
end