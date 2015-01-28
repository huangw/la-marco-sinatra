require 'yaml'
require 'google_translate'
require 'utils/hash_flatter'

# For i18n yaml files management
module I18nUtils
  class << self
    def google_t(key, lang)
      puts "retrieve translation for #{key} from google ..."
      trans = GoogleTranslate.new.translate(:en, lang, to_human(key))
      trans && trans[0] && trans[0][0] ? trans[0][0].first : nil
    end

    def to_human(key)
      key.to_s.titleize
    end

    def trans(key, lang)
      return to_human(key) if lang.to_sym == :en
      google_t(key, lang)
    end

    # find tt keys in file contents
    def find_tt_keys(contents)
      keys = []
      contents.map do |line|
        "=#{line}".scan(/\Wtt[\s\(]+\:([\w\'\"]+)/).each { |m| keys << m[0] }
      end
      keys.uniq
    end

    # find tt keys in file contents
    def find_fail_keys(contents)
      keys = []
      contents.map do |line|
        line.scan(/(fail|raise)\s+([A-Z]\w+)\,\s+\:(\w+)/).each do |m|
          keys << m[1..2].map(&:underscore).join('.')
        end
      end
      keys.uniq
    end
  end

  # handle an single yaml file with OOP
  # rubocop:disable LineLength
  class YamlFile
    include HashFlatter
    attr_reader :filename, :locale, :flat_hash

    def initialize(file_name)
      @filename = file_name # relative to root
      create_file(file_name) unless File.exist?(file_name)
      @as_hash = YAML.load_file(filename)
      @locale = @as_hash.keys.first || File.basename(file_name).sub(/\.yml\Z/, '')

      @flat_hash = {}
      hash_flat(@as_hash).each { |k, v| add_key(scope_join(*k), v) }

      @common_scope = find_common_scope(@flat_hash.keys)
    end

    def create_file(file)
      lc = File.basename(file).sub(/\.yml\Z/, '')
      fail "#{lc} not supported in #{I18n.available_locales.join(', ')}" unless I18n.available_locales.include?(lc.to_sym)
      dir = File.dirname(file)
      FileUtils.mkdir_p(dir) unless File.exist?(dir)
      File.open(file, 'w') { |fh| fh.write YAML.dump({}) }
    end

    def flat_keys
      flat_hash.keys
    end

    def add_key(key, value = nil)
      warn "[WARN] key #{key} exists" if key?(key)
      @flat_hash[scope_join(key)] ||= value
    end

    def add_with_gt(key, trans_key = -1)
      trans_key = key.split('.')[trans_key] if trans_key.is_a?(Integer)
      trans_key ||= key

      add_key(key, I18nUtils.trans(trans_key, @locale)) unless key?(scope_join(key))
    end

    def key?(key)
      @flat_hash[scope_join(key)] ? true : false
    end

    def renest
      nhsh = {}
      @flat_hash.each do |k, v|
        nhsh.deep_merge! hash_nest(k.split('.'), v)
      end
      nhsh
    end

    def rewrite!(file = @filename)
      File.open(file, 'w') { |wfh| wfh.write YAML.dump(renest) }
    end

    def find_common_scope(keys)
      return false if keys.empty?
      common_part = keys[0]
      keys[1..-1].each { |k| common_part = common_part.common_head(k) }
      common_part
    end

    def scope_join(*args)
      args.map { |k| k.to_s.sub(/\A\./, '').sub(/\.\Z/, '') }.join('.')
    end
  end
end
