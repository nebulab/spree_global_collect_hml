require 'spec_helper'

describe Spree::GlobalCollectCheckoutsController do
  context 'create' do
    let!(:global_collect_checkout) do
      FactoryGirl.create(:global_collect_checkout)
    end

    context 'when required params are missing' do
      context 'when ORDERID param is not provided' do
        it 'raises ActiveRecord::RecordNotFound' do
          expect { post :create, use_route: :spree }
            .to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'when CCLASTFOURDIGITS is not provided' do
        it 'raises ActionController::ParameterMissing' do
          expect do
            post :create, use_route: :spree,
                          'ORDERID' => global_collect_checkout.order_number,
                          'EXPIRYDATE' => '0122'
          end.to raise_error(ActionController::ParameterMissing)
        end
      end

      context 'when EXPIRYDATE is not provided' do
        it 'raises ActionController::ParameterMissing' do
          expect do
            post :create, use_route: :spree,
                          'ORDERID' => global_collect_checkout.order_number,
                          'CCLASTFOURDIGITS' => '1234'
          end.to raise_error(ActionController::ParameterMissing)
        end
      end
    end

    context 'when params are present' do
      before do
        expect_any_instance_of(Spree::GlobalCollectCheckout)
          .to receive(:update_attributes).with(
            cc_last_four_digits: '1234',
            expiry_date:         '0122'
          ).and_return(true)
      end

      it 'saves credit card details' do
        post :create, use_route: :spree,
                      'ORDERID' => global_collect_checkout.order_number,
                      'CCLASTFOURDIGITS' => '1234',
                      'EXPIRYDATE' => '0122'

        expect(response.body).to eql 'OK\n'
      end
    end
  end
end
