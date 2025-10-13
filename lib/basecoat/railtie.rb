module Basecoat
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path("../tasks/basecoat.rake", __dir__)
    end

    config.app_generators do |g|
      g.templates.unshift File.expand_path("../../templates", __dir__)
    end
  end
end
