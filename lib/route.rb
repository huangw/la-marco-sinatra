require 'active_support/inflector/inflections' # :underscore

# global route table
class Route
  class << self
    def table
      @table ||= {} # ControllerClass => '/maunt/point'
    end

    # Reversed mounting table:
    # '/maunt/point' => ControllerClass
    def all
      Hash[table.map { |k, rt| [rt, k.new] }]
    end

    # add class to specific route
    def []=(app_class, route)
      table[app_class] = route.to_s
    end

    # if key is a string, return class, otherwise return the path
    def [](key)
      return table[key] if key.is_a?(Class)
      return all[key].class if key.is_a?(String)
      nil
    end

    # add class to default route
    def mount(app_class, route = nil)
      route ||= default_path(app_class)
      table[app_class] = route
    end
    alias_method :'<<', :mount

    # To helper receive model as inputs:
    def to(app_class, *parts)
      prefix = app_class.is_a?(Class) ? @table[app_class] : app_class.to_s
      fail "unknown controller #{app_class}" if prefix.nil?
      return prefix unless parts && parts.size > 0

      if parts.last.is_a?(Hash)
        pam = '?' + parts.pop.map { |k, v| k.to_s + '=' + v.to_s }.join('&')
      end
      pam ||= ''
      pas = parts.map { |k| k.to_s.underscore.tr('_', '/') }

      File.join(prefix, *pas) + pam
    end

    def default_path(app_class)
      app_class.to_s.underscore.sub(/_(api|page|controller)\Z/, '')
        .sub(/^\/*/, '/').pluralize.tr('_', '/')
    end
  end
end
