begin
  require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'

  module ScaffoldControllerGeneratorPatch
    def create_controller_files
      super
      add_to_sidebar
    end

    def add_to_sidebar
      aside_path = 'app/views/layouts/_aside.html.erb'
      return unless File.exist?(aside_path)

      link_html = <<~HTML
            <li>
              <%= link_to #{plural_table_name}_path, data: { turbo_frame: "main_content", turbo_action: "advance" } do %>
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="m7 11 2-2-2-2" />
                  <path d="M11 13h4" />
                  <rect width="18" height="18" x="3" y="3" rx="2" ry="2" />
                </svg>
                <span>#{human_name.pluralize}</span>
              <% end %>
            </li>

      HTML

      inject_into_file aside_path, link_html, before: /\s*<\/ul>/
      say "Added #{human_name.pluralize} to sidebar", :green
    end
  end

  Rails::Generators::ScaffoldControllerGenerator.prepend(ScaffoldControllerGeneratorPatch)
rescue LoadError, NameError
  # Generators not loaded, skip this initializer
end
