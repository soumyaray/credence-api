# frozen_string_literal: true

require 'json'
require 'sequel'

module Credence
  # Models a secret document
  class Document < Sequel::Model
    many_to_one :project

    plugin :uuid, field: :id

    plugin :whitelist_security
    set_allowed_columns :filename, :relative_path, :description, :content

    plugin :timestamps, update_on_create: true

    def description
      SecureDB.decrypt(self.description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def content
      SecureDB.decrypt(self.content_secure)
    end

    def content=(plaintext)
      self.content_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'document',
          id: id,
          filename: filename,
          relative_path: relative_path,
          description: description,
          content: content,
          project: project
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
