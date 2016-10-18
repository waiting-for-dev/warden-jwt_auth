# frozen_string_literal: true

module Fixtures
  def self.user_repo
    Class.new do
      def self.find_for_jwt_authentication(_sub)
        :an_user
      end
    end
  end

  def self.user
    Class.new do
      def self.jwt_subject
        1
      end
    end
  end
end
