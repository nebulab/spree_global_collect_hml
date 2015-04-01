require 'spec_helper'

describe 'Global Collect', js: true do
  let!(:product) { FactoryGirl.create(:product, name: 'iPad') }

  before do
    @gateway = Spree::Gateway::GlobalCollectHml.create!(
      preferred_merchant_id: '123', name: 'Global Collect Hml', active: true,
      environment: 'test'
    )
    FactoryGirl.create(:shipping_method)
  end

  def fill_in_billing
    within('#billing') do
      fill_in 'First Name', with: 'Test'
      fill_in 'Last Name', with: 'User'
      fill_in 'Street Address', with: '1 User Lane'
      fill_in 'City', with: 'Adamsville'
      select 'United States of America', from: 'order_bill_address_attributes_country_id'
      select 'Alabama', from: 'order_bill_address_attributes_state_id'
      fill_in 'Zip', with: '35005'
      fill_in 'Phone', with: '555-123-4567'
    end
  end

  it 'pays for an order successfully' do
    visit spree.root_path
    click_link 'iPad'
    click_button 'Add To Cart'
    click_button 'Checkout'
    within('#guest_checkout') do
      fill_in 'Email', with: 'test@example.com'
      click_button 'Continue'
    end
    fill_in_billing
    click_button 'Save and Continue'
    # Delivery step doesn't require any action
    click_button 'Save and Continue'
    find('#global_collect_cc').click

    expect(page).to have_content('Your order has been processed successfully')

    Spree::Payment.last.source.transaction_id.should_not be_blank
  end
end
