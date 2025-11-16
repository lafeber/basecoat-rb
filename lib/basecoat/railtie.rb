module Basecoat
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path("../tasks/basecoat.rake", __dir__)
    end

    config.app_generators do |g|
      g.templates.unshift File.expand_path("../templates", __dir__)
    end

    initializer "basecoat.form_builder" do
      ActiveSupport.on_load(:action_view) do
        ActionView::Helpers::FormBuilder.include Basecoat::FormBuilder
      end
    end
  end
end
