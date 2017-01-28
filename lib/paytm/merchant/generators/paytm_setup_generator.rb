InitializerContent = "# Paytm initializer to setup with configurations
Paytm.config do |paytm|
  # paytm.base_uri = 'Some Base URI' # Default is staging api URI fpr paytm
  paytm.merchant_guid = 'Paytm Merchant Guid'
  paytm.aes_key = 'Paytm AES Key'
  paytm.sales_wallet_id = 'Paytm Sales Wallet Id'
end
"

class PaytmSetupGenerator < Rails::Generators::Base
  desc "This generator creates an initializer file at config/initializers"
  def create_initializer_file
    create_file("config/initializers/paytm.rb", InitializerContent)
  end
end
