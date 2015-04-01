require 'spec_helper'

describe Spree::GlobalCollectHml::CreditCardPaymentsController do
  context 'when current_order is nil' do
    before do
      allow(controller).to receive(:current_order).and_return(nil)
      allow(controller).to receive(:current_spree_user).and_return(nil)
    end

    context 'create' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect { post :create, use_route: :spree }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context 'when current_order is present' do
    let(:order) { OrderWalkthrough.up_to(:delivery) }

    before do
      Spree::Gateway::GlobalCollectHml::CreditCard.create!(
        preferred_merchant_id: '123', name: 'Global Collect Hml', active: true,
        environment: 'test')

      allow(controller).to receive(:current_order).and_return(order)
      allow(controller).to receive(:current_spree_user).and_return(order.user)

      expect(Spree::Gateway::GlobalCollectHml::CreditCard)
        .to receive(:prepare).and_return('http://formaction-url.com')
    end

    context 'create' do
      it 'calls pay_with_credit_card and redirects to the returned url' do
        expect(post :create, use_route: :spree)
          .to redirect_to('http://formaction-url.com')
      end
    end
  end
end
