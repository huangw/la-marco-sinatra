require 'google_translate'
# i18n update helpers for local development
module I18nUpdator
  def self.fetch_view_keys(contents)
    keys = []
    contents.map do |line|
      "=#{line}".scan(/\Wtt[\s\(]+\:(\w+)/).each { |m| keys << m[0] }
    end
    keys
  end

  def self.gtrans(key, lang)
    trans = GoogleTranslate.new.translate(:en, lang, key)
    trans && trans[0] && trans[0][0] ? trans[0][0].first : nil
  end

  def self.to_human(key)
    key.to_s.titleize
  end
end
