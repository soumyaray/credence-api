# frozen_string_literal: true

module Credence
  # Error for invalid credentials
  class UnauthorizedError < StandardError
    def initialize(msg = nil)
      @credentials = msg
    end

    def message
      "Invalid Credentials for: #{@credentials[:username]}"
    end
  end

  # Find account and check password
  class AuthenticateEmailAccount
    def self.call(credentials)
      account = EmailAccount.first(username: credentials[:username])
      raise StandardError unless account.password?(credentials[:password])

      { account: account, auth_token: AuthToken.create(account) }
    rescue StandardError
      raise UnauthorizedError, credentials
    end
  end
end
