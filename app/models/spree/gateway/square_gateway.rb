module Spree
  class Gateway::SquareGateway < Gateway
    preference :access_token, :string
    preference :application_id, :string
    preference :location_id, :string
    preference :api_version, :string

    def provider_class
      ActiveMerchant::Billing::SquareGateway
    end

    def purchase(money, creditcard, options)
      idempotency_key = SecureRandom.hex(10)
      square_option = {
        email: options['customer'],
        billing_address: options['billing_address'],
        idempotency_key: idempotency_key
      }
      # options =>  { email:"gary.lai@marigen.us",
      #       customer: "gary.lai@marigen.us",
      #       customer_id: 1,
      #       ip: "127.0.0.1",
      #       order_id: "R771169729-PMPERROT",
      #       shipping: 0.5e3,
      #       tax: 0.27e3,
      #       subtotal: 0.2699e4,
      #       discount: 0.0,
      #       currency: "USD",
      #       billing_address: {
      #         name: "Gary Lai",
      #         address1: "1200 E HILLSDALE BLVD",
      #         address2: "APT 231", city: "FOSTER CITY", state: "CA", zip: "94404", country: "US", phone: "4707862719"
      #       },
      #       shipping_address: {
      #         name: "Gary Lai",
      #         address1: "1200 E HILLSDALE BLVD",
      #         address2: "APT 231",
      #         city: "FOSTER CITY",
      #         state: "CA",
      #         zip: "94404",
      #         country: "US",
      #         phone: "4707862719"
      #       },
      #       idempotency_key: "346bd73e766f0e981c95" }
      provider.purchase(money, creditcard.try(:gateway_payment_profile_id), square_option)
    end

    def credit(money, creditcard, response_code, options={})
      idempotency_key = SecureRandom.hex(10)
      options.merge!({
        idempotency_key: idempotency_key
      })
      provider.refund(money, creditcard, options)
    end
  end
end
