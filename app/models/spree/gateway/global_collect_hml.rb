module Spree
  class Gateway::GlobalCollectHml < Gateway
    preference :merchant_id, :string

    def method_type
      'global_collect_hml'
    end
  end
end
