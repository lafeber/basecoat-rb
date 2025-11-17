module Basecoat
  module FormHelper
    def basecoat_select_tag(name, choices, options = {})
      select_id = "select-#{SecureRandom.random_number(1000000)}"
      selected_value = options[:selected] || choices.first[1]
      selected_choice = choices.find { |label, val| val.to_s == selected_value.to_s }
      selected_label = selected_choice ? selected_choice[0] : choices.first[0]

      group_label = options[:group_label] || name.to_s.titleize.pluralize
      placeholder = options[:placeholder] || "Search entries..."

      content_tag(:div, id: select_id, class: "select") do
        basecoat_select_button(select_id, selected_label) +
        basecoat_select_popover(select_id, choices, group_label, placeholder, selected_value) +
        tag(:input, type: "hidden", name: name, value: selected_value)
      end
    end

    private

    def basecoat_select_button(select_id, selected_label)
      content_tag(:button, type: "button", class: "btn-outline justify-between font-normal w-[180px]", id: "#{select_id}-trigger", "aria-haspopup": "listbox", "aria-expanded": "false", "aria-controls": "#{select_id}-listbox") do
        content_tag(:span, selected_label, class: "truncate") +
        basecoat_select_chevron_icon
      end
    end

    def basecoat_select_popover(select_id, choices, group_label, placeholder, selected_value)
      content_tag(:div, id: "#{select_id}-popover", data: { popover: true }, "aria-hidden": "true") do
        basecoat_select_search_header(select_id, placeholder) +
        basecoat_select_listbox(select_id, choices, group_label, selected_value)
      end
    end

    def basecoat_select_search_header(select_id, placeholder)
      content_tag(:header) do
        basecoat_select_search_icon +
        tag(:input, type: "text", value: "", placeholder: placeholder, autocomplete: "off", autocorrect: "off", spellcheck: "false", "aria-autocomplete": "list", role: "combobox", "aria-expanded": "false", "aria-controls": "#{select_id}-listbox", "aria-labelledby": "#{select_id}-trigger")
      end
    end

    def basecoat_select_listbox(select_id, choices, group_label, selected_value)
      content_tag(:div, role: "listbox", id: "#{select_id}-listbox", "aria-orientation": "vertical", "aria-labelledby": "#{select_id}-trigger") do
        content_tag(:div, role: "group", "aria-labelledby": "group-label-#{select_id}-items-1") do
          content_tag(:div, group_label, role: "heading", id: "group-label-#{select_id}-items-1") +
          choices.map.with_index do |(label, value), index|
            basecoat_select_option(select_id, label, value, index + 1, value.to_s == selected_value.to_s)
          end.join.html_safe
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

    def basecoat_select_chevron_icon
      content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round", class: "lucide lucide-chevrons-up-down-icon lucide-chevrons-up-down text-muted-foreground opacity-50 shrink-0") do
        tag(:path, d: "m7 15 5 5 5-5") +
        tag(:path, d: "m7 9 5-5 5 5")
      end
    end

    def basecoat_select_search_icon
      content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round", class: "lucide lucide-search-icon lucide-search") do
        tag(:circle, cx: "11", cy: "11", r: "8") +
        tag(:path, d: "m21 21-4.3-4.3")
      end
    end
  end
end
