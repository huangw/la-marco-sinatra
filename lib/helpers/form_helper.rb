require 'active_support/inflector'

# brought from https://github.com/cymen/sinatra-formhelpers-
# rubocop:disable LineLength, MethodLength, CyclomaticComplexity, ModuleLength
module FormHelper
  # a intermediate object holds default values passed to form helper
  class FormBuilder
    def initialize(parent, object, name = nil)
      @parent = parent
      if object.is_a?(Symbol) || object.is_a?(String)
        @object = object.to_sym
        @name = name || object.to_sym
      else
        @name = name || object.class.to_s.underscore.sub(/^.*\//, '').to_sym
        @object = object
      end
    end

    def field_group(field, options = {})
      type = options.delete(:type) || :text
      cls = 'form-group'

      e_msg = [options.delete(:e_msg1)] if options[:e_msg1]
      e_msg ||= @object.errors.messages[field] if @object.respond_to?(:errors)

      cls << ' has-error' if e_msg && e_msg.size > 0 && options.delete(:add_error_class)

      display = options.delete(:label) if options[:label]
      display ||= @object.class.human_attribute_name(field) if @object.class
                                                               .respond_to?(:human_attribute_name)
      out = label field, display, class: 'control-label'

      if block_given?
        out << yield
      else
        if type == :textarea
          out << textarea(field, options.delete(:value),
                          options.merge(class: 'form-control'))
        else
          out << send(type, field, options.merge(class: 'form-control'))
        end
      end

      if (icon_text = options.delete(:icon)) && (icon_type = options.delete(:icon_type))
        out << "<a class='icon #{icon_type}' popover-trigger='mouseenter' popover='#{icon_text}' href='javascript:void(0)'></a>"
      end

      out << @parent.tag(:p, e_msg.join('; '),
                         class: 'help-block') if e_msg && e_msg.size > 0

      @parent.tag :div, out, class: cls
    end

    def label(field, display = nil, options = {})
      options[:for] = "#{@name}_#{field}"
      @parent.label(field, display, options)
    end

    def default_value(field, default)
      v = @parent.params[@name] && @parent.params[@name][field.to_sym]
      v ||= @object.send(field.to_sym) if @object.respond_to?(field.to_sym)
      v || default
    end

    def textarea(field, contents = nil, options = {})
      options[:id] ||= "#{@name}_#{field}"
      contents ||= default_value(field, '')
      @parent.textarea("#{@name}[#{field}]", contents, options)
    end

    def radio(field, values, options = {})
      options[:id] ||= "#{@name}_#{field}"
      options[:value] = default_value(field, '')
      @parent.radio("#{@name}[#{field}]", values, options)
    end

    def checkbox(field, values, options = {})
      options[:id] ||= "#{@name}_#{field}"
      options[:value] = default_value(field, [])
      @parent.checkbox("#{@name}[#{field}]", values, options)
    end

    def select(field, values, options = {})
      options[:id] ||= "#{@name}_#{field}"
      options[:value] = default_value(field, '')
      @parent.select("#{@name}[#{field}]", values, options)
    end

    # return the checkbox keys, default is {on: }
    def default_bit_value(field, key, default)
      v = @parent.params[@name] &&
          @parent.params[@name][field.to_sym] &&
          @parent.params[@name][field.to_sym][key.to_sym]

      mto = field.to_s + '_' + key.to_s + '?'
      v ||= @object.send(mto.to_sym) if @object.respond_to?(mto.to_sym)
      v || default
    end

    def bit_checkbox(field, key, options = {})
      v = default_bit_value(field, key, false)

      display = options.delete(:label) if options[:label]
      display ||= @object.class.human_attribute_name(field.to_s + '_' + key.to_s) if @object.class.respond_to?(:human_attribute_name)

      options[:checked] = 'checked' if v
      @parent.checkbox("#{@name}[#{field}]", { key.to_sym => display }, options)
    end

    def bool_field_checkbox(field, options = {})
      v = default_value(field, false)

      display = options.delete(:label) if options[:label]
      display ||= @object.class.human_attribute_name(field) if @object.class.respond_to?(:human_attribute_name)

      options[:checked] = 'checked' if v
      @parent.checkbox("#{@name}[#{field}]", { '1': display }, options)
    end

    def method_missing(met, field = '', options = {})
      unless [:submit, :reset, :button].include? met
        options[:id] ||= "#{@name}_#{field}"
        field = field.to_sym if field
        options[:value] ||= @parent.params[@name] &&
                            @parent.params[@name][field]
        if !options[:value] && @object.respond_to?(field)
          options[:value] = @object.send(field)
        end

        field = "#{@name}[#{field}]"
      end

      @parent.send(met, field, options)
    end
  end

  def form(action = :self, options = {})
    action = request.path.sub(/^\/?/, '/') if action == :self

    met = options.delete(:method) || 'POST'
    hid_met = ''
    unless %w(POST GET).include?(met.to_s.upcase)
      hid_met = hidden('_method', value: met.to_s.upcase)
      met = :post
    end

    options[:enctype] = 'multipart/form-data' if options.delete(:upload)
    out = tag(:form, nil, { action: action, method: met.to_s.upcase }
              .merge(options)) << hid_met

    out << yield << close_tag('form') if block_given?
    out
  end

  def form_for(object, action = :self, options = {})
    fail ArgumentError, 'Missing block to form_for()' unless block_given?

    err_msg = ''
    add_err_msg = options.delete(:add_err_msg)

    if object.respond_to?(:errors) && object.errors.messages.keys.count > 0 && add_err_msg
      err_msg = I18n.t 'activerecord.errors.template.header',
                       count: object.errors.messages.keys.count,
                       model: object.class.model_name.human
    end

    out = yield(FormBuilder.new(self, object, options.delete(:name))) || ''
    err_msg << form(action, options) << out << close_tag('form')
  end

  def fieldset(legend = nil)
    legend = legend ? "<legend>#{fast_escape_html(legend)}</legend>" : ''
    tag(:fieldset) << legend
  end

  def close_fieldset
    close_tag('fieldset')
  end

  def fieldset_for(object, name = nil, legend = nil)
    fail ArgumentError, 'Missing block to fieldset()' unless block_given?
    legend ||= object.respond_to?(:model_name) ? object.model_name.human : object.class.to_s
    out = yield(FormBuilder.new(self, object, name)) || ''
    fieldset(legend) << out << close_fieldset
  end

  # add default values for the options argument
  def set_options(type, field, options = {})
    opts = {}
    opts[:type] = type
    opts[:name] = options.delete(:name) || field.to_s.underscore.to_sym
    opts[:id] = options.delete(:id) || css_id(opts[:name])
    options[:value] = params[opts[:name]] if params[opts[:name]]
    opts.merge(options)
  end

  # Form field label
  def label(field, display = '', options = {})
    display = field.to_s.capitalize if display.nil? || display == ''
    options[:for] ||= css_id(field)
    tag :label, display, options
  end

  def textarea(field, contents = '', options = {})
    opts = set_options(:textarea, field, options)
    opts.delete(:type)
    tag :textarea, contents, opts
  end

  def hidden(field, options = {})
    single_tag(:input, set_options(:hidden, field, options))
  end

  def text(field, options = {})
    single_tag(:input, set_options(:text, field, options))
  end

  def password(field, options = {})
    single_tag(:input, set_options(:password, field, options))
  end

  # General purpose button, usually these need JavaScript hooks.
  def button(value = nil, options = {})
    field = options[:name] || 'button'
    value = 'Button' if value.nil? || value == ''
    options[:value] ||= value
    single_tag(:input, set_options(:button, field, options))
  end

  def submit(value = nil, options = {})
    field = options[:name] || 'submit'
    value = 'Submit' if value.nil? || value == ''
    options[:value] ||= value
    single_tag(:input, set_options(:submit, field, options))
  end

  def reset(value = nil, options = {})
    field = options[:name] || 'reset'
    value = 'Reset' if value.nil? || value == ''
    options[:value] ||= value
    single_tag(:input, set_options(:reset, field, options))
  end

  def radio(field, values, options = {})
    opts = set_options(:radio, field, options)
    join_ = options.delete(:join) || ' '

    values = [values] if values.is_a?(String) || values.is_a?(Symbol)
    values = Hash[values.map { |k| [k.to_s, k.to_s] }] if values.is_a?(Array)

    id = opts.delete(:id)
    vals = opts.delete(:value) || ''
    values.map do |value_, label_|
      opts_ = opts.dup
      opts_[:id] = "#{id}_#{value_.to_s.underscore}"
      opts_[:value] = value_
      opts_[:checked] = 'checked' if vals.to_s == value_.to_s
      single_tag(:input, opts_) + ' ' + label(opts_[:id], label_)
    end.join(join_)
  end

  def checkbox(field, values, options = {})
    opts = set_options(:checkbox, field, options)
    opts[:name] = "#{opts[:name]}[]".to_sym
    join_ = options.delete(:join) || ' '

    values = [values] if values.is_a?(String) || values.is_a?(Symbol)
    values = Hash[values.map { |k| [k.to_s, k.to_s] }] if values.is_a?(Array)

    id = opts.delete(:id)
    vals = opts.delete(:value) || []
    vals = vals.map(&:to_s)
    values.map do |value_, label_|
      opts_ = opts.dup
      opts_[:id] = "#{id}_#{value_.to_s.underscore}"
      opts_[:value] = value_
      opts_[:checked] = 'checked' if vals.include?(value_.to_s)
      single_tag(:input, opts_) + ' ' + label(opts_[:id], label_)
    end.join(join_)
  end

  # Form select dropdown.  Currently only single-select
  # (not multi-select) is supported.
  def select(field, values, options = {})
    opts = set_options(:select, field, options)
    opts.delete(:type)

    values = [values] if values.is_a?(String) || values.is_a?(Symbol)
    values = Hash[values.map { |k| [k.to_s, k.to_s] }] if values.is_a?(Array)

    id = opts[:id]
    vals = opts.delete(:value) || ''
    content = values.map do |value_, label_|
      opts_ = {}
      opts_[:id] = "#{id}_#{value_.to_s.underscore}"
      opts_[:value] = value_
      opts_[:selected] = 'selected' if vals.to_s == value_.to_s
      tag :option, label_, opts_
    end.join('')

    tag :select, content, opts
  end

  # Standard open and close tags
  # EX : tag :h1, "shizam", :title => "shizam"
  # => <h1 title="shizam">shizam</h1>
  def tag(name, content = nil, options = {})
    "<#{name}" +
      (options.length > 0 ? " #{hash_to_html_attrs(options)}" : '') +
      (content.nil? ? '>' : ">#{content}</#{name}>")
  end

  # Standard single closing tags
  # single_tag :img, :src => "images/google.jpg"
  # => <img src="images/google.jpg" />
  def single_tag(name, options = {})
    if options.length > 0
      "<#{name} #{hash_to_html_attrs(options)} />"
    else
      "<#{name} />"
    end
  end

  def close_tag(name = 'form')
    "</#{name}>"
  end

  # quasi private
  def fast_escape_html(text)
    text.to_s.gsub(/\&/, '&amp;').gsub(/\"/, '&quot;')
      .gsub(/>/, '&gt;').gsub(/</, '&lt;')
  end

  def hash_to_html_attrs(options = {})
    html_attrs = []
    options.keys.each do |key|
      next if options[key].nil? # do not include empty attributes
      if options[key].is_a?(Symbol) && options[key] == :empty
        html_attrs << key.to_s
      else
        html_attrs << %(#{key}="#{fast_escape_html(options[key])}")
      end
    end
    html_attrs.join ' '
  end

  def css_id(*things)
    things.compact.map(&:to_s).join('_').downcase.gsub(/\W/, '_')
  end
end
