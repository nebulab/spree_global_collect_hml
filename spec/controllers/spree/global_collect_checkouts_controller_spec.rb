require 'spec_helper'

describe Spree::GlobalCollectCheckoutsController do
  context 'create' do
    let!(:global_collect_checkout) do
      FactoryGirl.create(:global_collect_payment).source
    end

    context 'when required params are missing' do
      context 'when ORDERID param is not provided' do
        it 'rescues ActiveRecord::RecordNotFound with NOK' do
          post :create, use_route: :spree

          expect(response.body).to eql "NOK\n"
        end
      end
    end

    context 'when params are present' do
      it 'completes an order and returns OK' do
        expect_any_instance_of(Spree::Payment)
          .to receive(:complete!).and_return(true)

        post :create, use_route: :spree,
                      'ORDERID'  => global_collect_checkout.order_number,
                      'STATUSID' => 800

        expect(response.body).to eql "OK\n"
      end

      it 'returns OK when STATUSID is under 800' do
        expect_any_instance_of(Spree::Payment).not_to receive(:complete!)

        post :create, use_route: :spree,
                      'ORDERID'  => global_collect_checkout.order_number,
                      'STATUSID' => 500

        expect(response.body).to be_blank
      end
    end
  end
end
