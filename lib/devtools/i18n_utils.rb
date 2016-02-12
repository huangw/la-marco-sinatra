require 'yaml'
require 'utils/hash_flatter'
require 'devtools/file_generator'

# For i18n yaml files management
# rubocop:disable LineLength
module I18nUtils
  class << self
    def google_t(key, lang)
      puts "retrieve translation for #{key} from google ..."
      EasyTranslate.translate(to_human(key), to: lang)
    end

    def to_human(key)
      key.to_s.titleize
    end

    def local_trans
      @local_trans ||= YAML.load(File.read(root_join('config/i18n_trans.yml')))
    end

    def trans(key, lang)
      return to_human(key) if lang.to_sym == :en
      local_t = local_trans && local_trans[lang.to_s] && local_trans[lang.to_s][key.underscore.to_s]
      local_t ? local_t : google_t(key, lang)
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
  class YamlFile
    include HashFlatter
    attr_reader :filename, :locale, :flat_hash, :added_keys

    def initialize(file_name)
      @filename = file_name # relative to root
      @as_hash = {}
      @as_hash = YAML.load_file(filename) if File.exist?(file_name)
      @locale = @as_hash.keys.first || File.basename(file_name).sub(/\.yml\Z/, '')

      @flat_hash = {}
      @added_keys = {}
      hash_flat(@as_hash).each { |k, v| add_key(scope_join(*k), v) }
      @added_keys = {} # workaround: cleanup added keys
      @common_scope = find_common_scope(@flat_hash.keys)
    end

    def flat_keys
      flat_hash.keys
    end

    def add_key(key, value = nil)
      skey = scope_join(key)
      return warn("[WARN] key #{skey} exists") if key?(skey)
      @added_keys[skey] = @flat_hash[skey] = value
    end

    def add_with_gt(key, trans_key = -1)
      trans_key = key.split('.')[trans_key] if trans_key.is_a?(Integer)
      trans_key ||= key

      add_key(key, I18nUtils.trans(trans_key, @locale)) unless key?(scope_join(key))
    end

    def key?(key)
      @flat_hash[key] ? true : false
    end

    def renest
      nhsh = {}
      @flat_hash.each do |k, v|
        nhsh.deep_merge! hash_nest(k.split('.'), v)
      end
      nhsh
    end

    def rewrite!(file = @filename)
      return 0 if @added_keys.keys.empty?
      puts "Update '#{file}' with:"
      ap @added_keys
      FileGenerator.wopen(file) { |wfh| wfh.write YAML.dump(renest) }
    end

    def find_common_scope(keys)
      return false if keys.empty?
      common_part = keys[0]
      keys[1..-1].each { |k| common_part = common_part.common_head(k) }
      common_part
    end

    def scope_join(*args)
      if @common_scope
        args.unshift @common_scope unless args[0] =~ /\A#{@common_scope}/
      end

      args.map { |k| k.to_s.sub(/\A\./, '').sub(/\.\Z/, '') }.join('.')
    end
  end
end
