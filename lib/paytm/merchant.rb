require "paytm/merchant/version"
require 'paytm/merchant/encryption_new_p_g'
require 'httparty'

module PayTM
  module Merchant

    def self.included(base)
      base.send :include, HTTParty
      base.extend EncryptionNewPG
      base.extend ClassMethods
    end

    # Class Variables
    @@base_uri = nil
    @@merchant_guid = nil
    @@aes_key = nil
    @@sales_wallet_id = nil

    # Constants
    Staging_Base_Uri = 'http://trust-uat.paytm.in'
    End_Points = {
      salestouser: '/wallet-web/salesToUserCredit',
      checkstatus: '/wallet-web/checkStatus'
    }

    # Attr_accessors
    attr_accessor :amount, :recipient, :phone, :email, :metadata

    # Class Methods
    module ClassMethods

      def base_uri=(value)
        @base_uri = value
      end
      def merchant_guid=(value)
        @merchant_guid = value
      end
      def aes_key=(value)
        @aes_key = value
      end
      def sales_wallet_id=(value)
        @sales_wallet_id = value
      end

      def config(&block)
        instance_eval(&block)
        set_httparty_base_uri
      end

      # Base URI for HTTParty requests
      def set_httparty_base_uri
        base_uri(@base_uri || Staging_Base_Uri)
      end

      def check_transaction_status_for(transaction_id, options = {})
        new.check_transaction_status_for transaction_id, options
      end
    end


    # Instance Methods
    def initialize(data = {})
      @amount = data[:amount]
      @recipient = data[:recipient]
      @phone = data[:phone]
      @email = data[:email]
    end

    def transfer(options = {})
      @amount = amount if options[:amount]

      @response = self.class.post(
        End_Points[:salestouser],
        { body: paytm_request_body(options).to_json, headers: paytm_request_headers }
      )
    end

    def check_transaction_status_for(transaction_id, options = {})
      check_transaction_body = paytm_check_transation_status_body(transaction_id, options)
      @response = self.class.post(
        End_Points[:checkstatus],
        {
          body: check_transaction_body.to_json,
          headers: paytm_check_transation_status_header(check_transaction_body)
        }
      )
    end


    private

    def paytm_check_transation_status_body(transaction_id, options = {})
      case options[:transaction_id_type]
      when :paytm_transaction_id
        request_type = 'wallettxnid' # Default
      when :merchant_order_id
        request_type = 'merchanttxnid'
      when :refund_reference_id
        request_type = 'refundreftxnid'
      else
        request_type = 'wallettxnid'
      end

      transaction_type = options[:transaction_type] || 'salestouser'

      {
        request: {
          requestType: request_type,
          txnType: transaction_type,
          txnId: transaction_id,
          merchantGuid: @@merchant_guid
        },
        platformName: 'PayTM',
        operationType: 'CHECK_TXN_STATUS'
      }
    end

    def paytm_check_transation_status_header(check_transaction_body)
      paytm_request_headers(check_transaction_body)
    end

    def paytm_request_body(options = {})
      {
        request: {
          requestType: options[:request_type],
          merchantGuid: @@merchant_guid,
          merchantOrderId: options[:merchant_order_id] || "#{ @phone }-#{ Time.current.to_i }",
          salesWalletName: options[:sales_wallet_name],
          salesWalletGuid: @@sales_wallet_id,
          payeeEmailId: @email,
          payeePhoneNumber: @phone,
          payeeSsoId: options[:payee_sso_id] || '',
          appliedToNewUsers: options[:applied_to_new_users] || 'Y',
          amount: @amount,
          currencyCode: options[:currency_code] || 'INR'
        },
        metadata: options[:metadata] || '',
        ipAddress: options[:ip_address] || '127.0.0.1',
        platformName: 'PayTM',
        operationType: 'SALES_TO_USER_CREDIT'
      }
    end

    def paytm_request_headers(request_body = paytm_request_body)
      {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'mid' => @@merchant_guid,
        'checksumhash' => generate_hash(@@aes_key, request_body)
      }
    end

    def generate_hash(key, params={})
      @checksum = Paytm.new_pg_checksum_by_str(params.to_json, key).gsub("\n",'')
    end
  end
end


class Paytm
  include PayTM::Merchant
end
