# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth do
  it 'has a version number' do
    expect(Warden::JWTAuth::VERSION).not_to be nil
  end
end
