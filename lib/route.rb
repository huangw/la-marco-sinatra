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
      route ||= default_path(app_class).gsub('_', '/')
      table[app_class] = route
    end
    alias_method :'<<', :mount

    # To helper receive model as inputs:
    def to(app_class, *parts)
      return nil unless @table[app_class]
      return @table[app_class] unless parts && parts.size > 0

      if parts.last.is_a?(Hash)
        pam = '?' + parts.pop.map { |k, v| k.to_s + '=' +  v.to_s }.join('&')
      end
      pam ||= ''
      pas = parts.map { |k| k.to_s.underscore.gsub('_', '/') }

      File.join(@table[app_class], *pas) + pam
    end

    def default_path(app_class)
      app_class.to_s.underscore.sub(/_(api|page|controller)$/, '')
        .sub(/^\/*/, '/').pluralize
    end
  end
end
