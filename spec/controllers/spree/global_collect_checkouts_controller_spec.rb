require 'spec_helper'

describe Spree::GlobalCollectCheckoutsController do
  context 'update' do
    let!(:global_collect_checkout) do
      FactoryGirl.create(:global_collect_checkout)
    end

    context 'when required params are missing' do
      context 'when ORDERID param is not provided' do
        it 'raises ActiveRecord::RecordNotFound' do
          expect { post :update, use_route: :spree }
            .to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'when CCLASTFOURDIGITS is not provided' do
        it 'raises ActionController::ParameterMissing' do
          expect do
            post :update, use_route: :spree,
                          'ORDERID' => global_collect_checkout.order_number,
                          'EXPIRYDATE' => '0122'
          end.to raise_error(ActionController::ParameterMissing)
        end
      end

      context 'when EXPIRYDATE is not provided' do
        it 'raises ActionController::ParameterMissing' do
          expect do
            post :update, use_route: :spree,
                          'ORDERID' => global_collect_checkout.order_number,
                          'CCLASTFOURDIGITS' => '1234'
          end.to raise_error(ActionController::ParameterMissing)
        end
      end
    end
  end
end
