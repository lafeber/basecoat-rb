module Basecoat
  module FormHelper
    ##
    # Renders a remote search component with Turbo Stream support.
    #
    # ==== Parameters
    # * +url+ - The URL to fetch search results from (required)
    # * +options+ - Hash of optional parameters:
    #   * +:turbo_frame+ - Custom turbo frame name (defaults to underscored URL)
    #   * +:placeholder+ - Custom placeholder text (defaults to "Type a command or search...")
    #   * +:data_empty+ - Message shown when no results found (defaults to "No results found.")
    #   * +:classes+ - Additional CSS classes to apply to the component
    #
    # ==== Examples
    #   <%= basecoat_remote_search_tag("/posts/search") %>
    #   <%= basecoat_remote_search_tag("/posts/search", turbo_frame: "custom_frame") %>
    #   <%= basecoat_remote_search_tag("/posts/search", placeholder: "Search posts...", classes: "rounded-lg border shadow-md") %>
    def basecoat_remote_search_tag(url, options = {})
      turbo_frame = options[:turbo_frame] || url.gsub("/", "_")
      placeholder = options[:placeholder] || "Type a command or search..."
      data_empty = options[:data_empty] || "No results found."
      classes = options[:classes] || ""
      search_id = "search-#{SecureRandom.random_number(1000000)}"

      content_tag(:div, id: search_id, data: { controller: "search", search_url_value: url }, class: "command #{classes}", "aria-label": "Command menu") do
        content_tag(:header) do
          lucide_icon("search").html_safe +
          tag(:input,
            type: "search",
            id: "#{search_id}-input",
            placeholder: placeholder,
            autocomplete: "off",
            autocorrect: "off",
            spellcheck: "false",
            "aria-autocomplete": "list",
            role: "combobox",
            "aria-expanded": "true",
            "aria-controls": "#{search_id}-menu",
            data: {
              search_target: "input",
              action: "input->search#search"
            }
          )
        end +
        content_tag(:div, role: "menu", id: "#{search_id}-menu", "aria-orientation": "vertical", data: { empty: data_empty }, class: "scrollbar") do
          turbo_frame_tag(turbo_frame)
        end
      end
    end

    ##
    # Renders a select component outside of a form context.
    #
    # ==== Parameters
    # * +name+ - The name attribute for the hidden input field (required)
    # * +choices+ - Array of [label, value] pairs for select options (required)
    # * +options+ - Hash of optional parameters:
    #   * +:selected+ - The initially selected value (defaults to first choice)
    #   * +:group_label+ - Label for the option group (defaults to titleized and pluralized name)
    #   * +:placeholder+ - Placeholder text for the search input (defaults to "Search entries...")
    #   * +:url+ - URL for remote search via Turbo Stream
    #   * +:turbo_frame+ - Custom turbo frame name when using +:url+ (defaults to underscored URL)
    #   * +:scrollable+ - Whether to make the listbox scrollable with max height (defaults to false)
    #
    # ==== Examples
    #   <%= basecoat_select_tag "fruit", [["Apple", 1], ["Pear", 2]] %>
    #   <%= basecoat_select_tag "fruit", [["Apple", 1], ["Pear", 2]], selected: 2, placeholder: "Search fruits..." %>
    #   <%= basecoat_select_tag "fruit", [], url: "/fruits/search", turbo_frame: "custom_frame", scrollable: true %>
    def basecoat_select_tag(name, choices, options = {})
      select_id = "select-#{SecureRandom.random_number(1000000)}"
      url = options[:url]

      if url || choices.empty?
        selected_value = options[:selected]
        selected_label = options[:selected_label] || "Select..."
      else
        selected_value = options[:selected] || choices.first[1]
        selected_choice = choices.find { |label, val| val.to_s == selected_value.to_s }
        selected_label = selected_choice ? selected_choice[0] : choices.first[0]
      end

      group_label = options[:group_label] || name.to_s.titleize.pluralize
      placeholder = options[:placeholder] || "Search entries..."
      scrollable = options[:scrollable] || false
      turbo_frame = options[:turbo_frame] || (url ? url.gsub("/", "_") : nil)

      select_attrs = { id: select_id, class: "select" }
      if url
        select_attrs[:data] = {
          controller: "search",
          search_url_value: url
        }
      end

      content_tag(:div, select_attrs) do
        basecoat_select_button(select_id, selected_label) +
        basecoat_select_popover(select_id, choices, group_label, placeholder, selected_value, url, scrollable, turbo_frame) +
        tag(:input, type: "hidden", name: name, value: selected_value)
      end
    end

    ##
    # Renders a country select component with flag emojis.
    #
    # ==== Parameters
    # * +name+ - The name attribute for the hidden input field (required)
    # * +options+ - Hash of optional parameters:
    #   * +:selected+ - The initially selected country code (e.g., "US")
    #   * +:countries+ - Array of country codes to include (defaults to all countries)
    #   * +:priority+ - Array of priority country codes to show at the top
    #   * +:except+ - Array of country codes to exclude
    #   * All other basecoat_select_tag options (placeholder, scrollable, etc.)
    #
    # ==== Examples
    #   <%= basecoat_country_select :country %>
    #   <%= basecoat_country_select :country, selected: "US" %>
    #   <%= basecoat_country_select :country, priority: ["US", "CA", "GB"] %>
    #   <%= basecoat_country_select :country, countries: ["US", "CA", "MX"] %>
    def basecoat_country_select(name, options = {})
      require 'countries'

      # Extract country-specific options
      country_codes = options.delete(:countries)
      priority_codes = options.delete(:priority) || []
      except_codes = options.delete(:except) || []

      # Get all countries or filtered list
      all_countries = if country_codes
        country_codes.map { |code| ISO3166::Country[code] }.compact
      else
        ISO3166::Country.all
      end

      # Remove excluded countries
      all_countries.reject! { |country| except_codes.include?(country.alpha2) } if except_codes.any?

      # Build choices with flag emoji
      choices = all_countries.map do |country|
        ["#{country.emoji_flag} #{country.iso_short_name}", country.alpha2]
      end

      # Sort alphabetically by country name
      choices.sort_by! { |label, _| label }

      # Add priority countries at the top
      if priority_codes.any?
        priority_choices = priority_codes.map do |code|
          country = ISO3166::Country[code]
          next unless country
          ["#{country.emoji_flag} #{country.iso_short_name}", country.alpha2]
        end.compact

        choices.reject! { |_, code| priority_codes.include?(code) }
        choices = priority_choices + [["---", nil]] + choices
      end

      # Update selected_label if a country is selected
      if options[:selected]
        country = ISO3166::Country[options[:selected]]
        options[:selected_label] = "#{country.emoji_flag} #{country.iso_short_name}" if country
      end

      # Set defaults
      options[:placeholder] ||= "Search countries..."
      options[:group_label] ||= "Countries"
      options[:scrollable] = true unless options.key?(:scrollable)

      basecoat_select_tag(name, choices, options)
    end

    private

    def basecoat_select_button(select_id, selected_label)
      content_tag(:button, type: "button", class: "btn-outline justify-between font-normal w-[180px]", id: "#{select_id}-trigger", "aria-haspopup": "listbox", "aria-expanded": "false", "aria-controls": "#{select_id}-listbox") do
        content_tag(:span, selected_label, class: "truncate") +
        lucide_icon("chevrons-up-down", class: "text-muted-foreground opacity-50 shrink-0").html_safe
      end
    end

    def basecoat_select_popover(select_id, choices, group_label, placeholder, selected_value, url, scrollable, turbo_frame)
      content_tag(:div, id: "#{select_id}-popover", data: { popover: true }, "aria-hidden": "true") do
        basecoat_select_search_header(select_id, placeholder) +
        basecoat_select_listbox(select_id, choices, group_label, selected_value, url, scrollable, turbo_frame)
      end
    end

    def basecoat_select_search_header(select_id, placeholder)
      content_tag(:header) do
        lucide_icon("search").html_safe +
        tag(:input, type: "text", value: "", placeholder: placeholder, autocomplete: "off", autocorrect: "off", spellcheck: "false", "aria-autocomplete": "list", role: "combobox", "aria-expanded": "false", "aria-controls": "#{select_id}-listbox", "aria-labelledby": "#{select_id}-trigger", data: { search_target: "input", action: "input->search#search" })
      end
    end

    def basecoat_select_listbox(select_id, choices, group_label, selected_value, url, scrollable, turbo_frame)
      listbox_attrs = {
        role: "listbox",
        id: "#{select_id}-listbox",
        "aria-orientation": "vertical",
        "aria-labelledby": "#{select_id}-trigger"
      }

      listbox_attrs[:class] = "scrollbar overflow-y-auto max-h-64" if scrollable

      if url
        listbox_attrs[:data] = {
          controller: "search",
          search_url_value: url
        }
      end

      content_tag(:div, listbox_attrs) do
        if url
          turbo_frame_tag(turbo_frame)
        else
          content_tag(:div, role: "group", "aria-labelledby": "group-label-#{select_id}-items-1") do
            content_tag(:div, group_label, role: "heading", id: "group-label-#{select_id}-items-1") +
            choices.map.with_index do |(label, value), index|
              basecoat_select_option(select_id, label, value, index + 1, value.to_s == selected_value.to_s)
            end.join.html_safe
          end
        end
      end
    end

    def basecoat_select_option(select_id, label, value, index, selected)
      content_tag(:div, label,
        id: "#{select_id}-items-1-#{index}",
        role: "option",
        "data-value": value,
        "aria-selected": selected
      )
    end
  end
end
