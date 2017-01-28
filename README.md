# Paytm Merchant

This is a ruby library(and not just rails gem) for PayTM Merchant transactions API. You can easily integrate you application to pay your users/winners by calling `Paytm.new({amount: 110, phone: '7777777777'}).transfer`

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'paytm-merchant'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paytm-merchant

## Usage

To setup, first initialize the library with credentials.

```ruby
Paytm.config do |paytm|
  # paytm.api_base_uri = 'Some Base URI' # Default is staging api URI fpr paytm
  paytm.merchant_guid = 'Paytm Merchant Guid'
  paytm.aes_key = 'Paytm AES Key'
  paytm.sales_wallet_id = 'Paytm Sales Wallet Id'
end
```

For Rails:

    $ rails generate paytm_setup

The above line will create a `paytm.rb` file initializes directory where you can update the credentials.


### Funtionality

Create paytm object of `Paytm` class.

```ruby
paytm_obj = Paytm.new(
  amount: 120,
  recipient: User.last,
  phone: '7777777777',
  email: 'user@example.com'
)
```

#### Transfer
```ruby
paytm_obj.transfer         # Returns the HTTParty response object
```

You can specify different options for transfer

```ruby
paytm_obj.transfer(
  request_type:         nil,                              # +nil+ for normal transfer request
  merchant_order_id:    'Unique id per transaction',      # Default order id is made using phone number and current timestamp
  sales_wallet_name:    'As per your paytm credentials',  # Leave blank if not known
  payee_sso_id:         'As per your paytm credentials',  # Leave blank if not known
  applied_to_new_users: 'Y',                              # 'Y' or 'N'; Whether to create paytm account for new phone no.
  amount:                150,
  currency_code:        'INR'                             # Currency code specified by Paytm. Default 'INR'
  metadata:             'Test Transaction',               # Extra details to be sent for transaction
  ip_address:            '127.0.0.1',                      # As you want
)
```

Response
```ruby
{"type"=>nil,
 "requestGuid"=>nil,
 "orderId"=>"7777777777-1485612494",
 "status"=>"SUCCESS",
 "statusCode"=>"SUCCESS",
 "statusMessage"=>"SUCCESS",
 "response"=>{"walletSysTransactionId"=>"515571"},
 "metadata"=>""}

```

#### Check Transaction
```ruby
paytm_obj.new.check_transaction_status_for('515571')      # First agrument is paytm wallet txn id recieved in txn response
```

You can specify different options
```ruby
paytm_obj.new.check_transaction_status_for(
  '515571',                                       # This id is the id as per in +transaction_id_type+ option
  {
    transaction_id_type: :paytm_transaction_id,   # Possible values, :paytm_transaction_id, :merchant_order_id, :refund_reference_id. Default is :paytm_transaction_id
    transaction_type: 'salestouser',              # Possible values as per Paytm API

  }
)
```

Response

```ruby
{
  "type"=>nil,
  "requestGuid"=>nil,
  "orderId"=>nil,
  "status"=>"SUCCESS",
  "statusCode"=>"SS_001",
  "statusMessage"=>"SUCCESS",
  "response"=>
    {"txnList"=>
      [{
        "txnGuid"=>"515323",
        "txnAmount"=>110,
        "status"=>1,
        "message"=>"SUCCESS",
        "txnErrorCode"=>nil,
        "ssoId"=>"11065108",
        "txnType"=>"SALES_TO_USER_CREDIT",
        "merchantOrderId"=>"7777777777-1485604732",
        "pgTxnId"=>"\"null\"",
        "pgRefundId"=>"\"null\"",
        "cashbackTxnId"=>nil,
        "isLimitPending"=>false
      }]
    },
  "metadata"=>nil
 }
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/schnmudgal/paytm. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

