# [Class] NokogiriHtmlElement
#   (lib/core_ext/nokogiri_html_element.rb)
# vi: foldlevel=1
# created at: 2016-02-24
require 'nokogiri'

# mixin Nokorigi
module Nokogiri
  # mixin Nokorigi::HTML
  module XML
    # mixin Nokorigi::HTML::Element, formalize id and class getter
    class Element
      def tid
        tid = attribute('id') && attribute('id').value
        tid.blank? ? nil : tid
      end

      def class?(klass)
        klasses = attribute('class')
        klasses = klasses ? klasses.value.split(/\s+/) : []
        klasses.map(&:downcase).include?(klass.downcase)
      end

      def classes?(klasses)
        klasses.each { |k| return k if class?(k) }
        nil
      end
    end
  end
end
