# frozen_string_literal: true

require 'roda'

module Credence
  # Web controller for Credence API
  class Api < Roda
    route('documents') do |routing|
      @doc_route = "#{@api_root}/documents"

      routing.get(String) do |doc_id|
        account = Account.first(username: @auth_account['username'])
        doc = Document.where(id: doc_id).first
        policy = DocumentPolicy.new(account, doc)
        raise unless policy.can_view?

        doc ? doc.to_json : raise
      rescue StandardError
        routing.halt 404, { message: 'Document not found' }.to_json
      end
    end
  end
end
