module Basecoat
  module FormBuilder
    def basecoat_select(method, choices, options = {}, html_options = {})
      select_id = "select-#{SecureRandom.random_number(1000000)}"
      value = @object.public_send(method) if @object
      selected_choice = choices.find { |label, val| val.to_s == value.to_s }
      selected_label = selected_choice ? selected_choice[0] : choices.first[0]
      selected_value = selected_choice ? selected_choice[1] : choices.first[1]

      group_label = options[:group_label] || method.to_s.titleize.pluralize
      placeholder = options[:placeholder] || "Search entries..."
      button_class = options[:button_class] || "btn-outline justify-between font-normal w-[180px]"

      @template.content_tag(:div, id: select_id, class: "select") do
        basecoat_button_html(select_id, selected_label) +
        basecoat_popover_html(select_id, choices, group_label, placeholder, selected_value) +
        basecoat_hidden_field_html(method, select_id, selected_value)
      end
    end

    private

    def basecoat_button_html(select_id, selected_label)
      @template.content_tag(:button, type: "button", class: "btn-outline justify-between font-normal w-[180px]", id: "#{select_id}-trigger", "aria-haspopup": "listbox", "aria-expanded": "false", "aria-controls": "#{select_id}-listbox") do
        @template.content_tag(:span, selected_label, class: "truncate") +
        basecoat_chevron_icon
      end
    end

    def basecoat_popover_html(select_id, choices, group_label, placeholder, selected_value)
      @template.content_tag(:div, id: "#{select_id}-popover", data: { popover: true }, "aria-hidden": "true") do
        basecoat_search_header(select_id, placeholder) +
        basecoat_listbox_html(select_id, choices, group_label, selected_value)
      end
    end

    def basecoat_search_header(select_id, placeholder)
      @template.content_tag(:header) do
        basecoat_search_icon +
        @template.tag(:input, type: "text", value: "", placeholder: placeholder, autocomplete: "off", autocorrect: "off", spellcheck: "false", "aria-autocomplete": "list", role: "combobox", "aria-expanded": "false", "aria-controls": "#{select_id}-listbox", "aria-labelledby": "#{select_id}-trigger")
      end
    end

    def basecoat_listbox_html(select_id, choices, group_label, selected_value)
      @template.content_tag(:div, role: "listbox", id: "#{select_id}-listbox", "aria-orientation": "vertical", "aria-labelledby": "#{select_id}-trigger") do
        @template.content_tag(:div, role: "group", "aria-labelledby": "group-label-#{select_id}-items-1") do
          @template.content_tag(:div, group_label, role: "heading", id: "group-label-#{select_id}-items-1") +
          choices.map.with_index do |(label, value), index|
            basecoat_option_html(select_id, label, value, index + 1, value.to_s == selected_value.to_s)
          end.join.html_safe
        end
      end
    end

    def basecoat_option_html(select_id, label, value, index, selected)
      @template.content_tag(:div, label,
        id: "#{select_id}-items-1-#{index}",
        role: "option",
        "data-value": value,
        "aria-selected": selected
      )
    end

    def basecoat_hidden_field_html(method, select_id, selected_value)
      @template.tag(:input, type: "hidden", name: "#{@object_name}[#{method}]", value: selected_value)
    end

    def basecoat_chevron_icon
      @template.content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round", class: "lucide lucide-chevrons-up-down-icon lucide-chevrons-up-down text-muted-foreground opacity-50 shrink-0") do
        @template.tag(:path, d: "m7 15 5 5 5-5") +
        @template.tag(:path, d: "m7 9 5-5 5 5")
      end
    end

    def basecoat_search_icon
      @template.content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round", class: "lucide lucide-search-icon lucide-search") do
        @template.tag(:circle, cx: "11", cy: "11", r: "8") +
        @template.tag(:path, d: "m21 21-4.3-4.3")
      end
    end
  end
end
