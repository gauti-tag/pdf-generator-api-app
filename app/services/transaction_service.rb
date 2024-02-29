require 'typhoeus'
require 'ostruct'
require 'securerandom'

class TransactionService < ApplicationService
    attr_reader :params

    # Initialize params 
    def initialize(params)
        @params = params
    end

    def call       
        url = "#{ENV['URL']}/check_payment_status/#{params[:order]}"
        request = Typhoeus::Request.new(
            url,
            method: :post,
            headers: { 
                Authorization: "Bearer #{auth}",
                'Accept-Encoding' => 'application/json',
                'Content-Type'=> 'application/json'
            },
            body: ''
        )
        request.run
        if request.response.code == 200
            response = JSON.parse(request.response.body)
            status = response['code'] == '1' ? 200 : 400
            OpenStruct.new(status: status, response: response)
        else
            OpenStruct.new(status: 400)
        end
                
    end

    private 

    def auth
        token = REDIS_CLIENT.get('gateway:token')
        if token.nil?
            auth_req = Typhoeus::Request.new("#{ENV['URL']}/auth", 
            method: :post,
            headers: { 'Accept-Encoding' => 'application/json', 'Content-Type'=> 'application/json'},
            body: auth_params.to_json
            )
            auth_req.run
            return if auth_req.response.code != 200  
            token = JSON.parse(auth_req.response.body)['auth_token']
            REDIS_CLIENT.setex('gateway:token', 1.hour.to_i, token)
        end
        token
    end
    
  
    def auth_params
    {
        auth: {
            name: ENV['SERVICE_NAME'],
            authentication_token: ENV['AUTH_TOKEN'],
            order: SecureRandom.uuid
        }
    }
    end
  
end