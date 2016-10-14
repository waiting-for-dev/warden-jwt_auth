# frozen_string_literal: true

require 'spec_helper'

describe Devise::Jwt do
  it 'has a version number' do
    expect(Devise::Jwt::VERSION).not_to be nil
  end
end
