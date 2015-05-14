require 'spec_helper'

describe Spree::GlobalCollectCheckout do
  let(:global_collect_checkout) { FactoryGirl.build(:global_collect_checkout) }

  context '#expiry_date=' do
    it 'is nil if nil is passed as argument' do
      global_collect_checkout.expiry_date = nil

      expect(global_collect_checkout.expiry_date)
        .to eql nil
    end

    it 'is nil if an empty value is passed as argument' do
      global_collect_checkout.expiry_date = ''

      expect(global_collect_checkout.expiry_date)
        .to eql nil
    end

    it 'casts expiry_date as a date' do
      global_collect_checkout.expiry_date = '1222'

      expect(global_collect_checkout.expiry_date)
        .to eql Date.new(2022, 12).end_of_month
    end
  end

  context '#cc_last_four_digits=' do
    it 'is nil if nil is passed as argument' do
      global_collect_checkout.cc_last_four_digits = nil

      expect(global_collect_checkout.cc_last_four_digits)
        .to eql nil
    end

    it 'is nil if an empty value is passed as argument' do
      global_collect_checkout.cc_last_four_digits = ''

      expect(global_collect_checkout.cc_last_four_digits)
        .to eql nil
    end

    it 'saves only the last 4 characters' do
      global_collect_checkout.cc_last_four_digits = '**************1222'

      expect(global_collect_checkout.cc_last_four_digits)
        .to eql '1222'
    end
  end
end
