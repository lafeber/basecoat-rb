module Basecoat
  module FormBuilder
    def basecoat_select(method, choices, options = {}, html_options = {})
      value = @object.public_send(method) if @object
      options = options.merge(selected: value) if value

      name = "#{@object_name}[#{method}]"
      options[:group_label] ||= method.to_s.titleize.pluralize

      @template.basecoat_select_tag(name, choices, options)
    end
  end
end
