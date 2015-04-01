require 'spec_helper'

describe Rails::Application::Configuration do
  subject { Rails.application.config.spree.payment_methods }

  it { should include(Spree::Gateway::GlobalCollectHml::CreditCard) }
end
