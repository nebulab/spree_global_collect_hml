require 'spec_helper'

describe Spree::GlobalCollectCheckoutsController do
  context 'create' do
    let!(:global_collect_checkout) do
      FactoryGirl.create(:global_collect_payment).source
    end

    context 'when required params are missing' do
      context 'when ORDERID param is not provided' do
        it 'raises ActiveRecord::RecordNotFound' do
          expect { post :create, use_route: :spree }
            .to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'when params are present' do
      before do
        expect_any_instance_of(Spree::Payment)
          .to receive(:capture!).and_return(true)
      end

      it 'saves credit card details' do
        post :create, use_route: :spree,
                      'ORDERID' => global_collect_checkout.order_number

        expect(response.body).to eql 'OK\n'
      end
    end
  end
end
