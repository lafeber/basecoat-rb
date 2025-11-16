# frozen_string_literal: true

require_relative "basecoat/version"
require_relative "basecoat/railtie" if defined?(Rails)
require_relative "basecoat/form_builder" if defined?(Rails)
require_relative "basecoat/form_helper" if defined?(Rails)

module Basecoat
  class Error < StandardError; end
end
