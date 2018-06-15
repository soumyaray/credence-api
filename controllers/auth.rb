# frozen_string_literal: true

require 'roda'

module Credence
  # Web controller for Credence API
  class Api < Roda
    route('auth') do |routing|
      routing.on 'authenticate' do
        routing.route('authenticate', 'auth')
      end

      routing.on 'register' do
        # POST api/v1/auth/register
        routing.post do
          registration = SignedRequest.new(Api.config)
                                      .parse(request.body.read)
          EmailVerification.new(Api.config).call(registration)

          response.status = 201
          { message: 'Verification email sent' }.to_json
        rescue InvalidRegistration => error
          routing.halt 400, { message: error.message }.to_json
        rescue StandardError => error
          puts "ERROR VERIFYING REGISTRATION: #{error.inspect}"
          puts error.message
          routing.halt 500
        end
      end
    end
  end
end
