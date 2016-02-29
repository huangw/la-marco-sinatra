require 'asset_settings'
%w(pull sfile vendor_file cloud_file tfile producer loader).each do |f|
  require_relative "asset_mapper/#{f}"
end

# Used by rake tasks, update `config.yml` file, update local js/css files, or
# compile minimized version of assets for production use.
module AssetMapper
  DEFAULTS = {
    pull_dir: File.join(Dir.home, '.assets_mapper'),
    assets_dir: 'app/assets', # directory for source js files
    vendor_dir: 'app/assets/vendor',
    # js/css files copied from 3rd party repository
    cloud_dir: 'app/assets/cloud',
    # local file cache for cloud js/css files
    min_dir: 'app/assets/min' # directory for minimized js/css files
  }.freeze

  class << self
    attr_accessor :compile

    DEFAULTS.each do |met, default_value|
      define_method met do |val = nil|
        instance_variable_set("@#{met}", val) unless val.nil?
        instance_variable_get("@#{met}") || default_value
      end
    end

    def root
      ENV['APP_ROOT']
    end

    def compile?
      @compile ? true : false
    end
  end
end
