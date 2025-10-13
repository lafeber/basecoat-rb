module Basecoat
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path("../tasks/basecoat.rake", __dir__)
    end
  end
end
