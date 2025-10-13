# frozen_string_literal: true

require_relative "basecoat/version"
require_relative "basecoat/railtie" if defined?(Rails)

module Basecoat
  class Error < StandardError; end
end
