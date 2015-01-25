require_relative 'pull'
# mix-in the name space
module AssetsMapper
  # DSL command available directly in the mapping ruby file, top scope
  class Loader
    def initialize(root, file = nil)
      @config = AssetsMapper.config
    end

    def load!(command) # :map, :update and :compile
      @command = command
      rfile = File.join(root, @config.mapping_file) # create absolute path
      instance_eval File.read(rfile), rfile
    end

    # Global DSL implementations
    # ------------------------------
    def pull(app_name, opts)
      to = opts.extract(to: @config.pull_dir)
      Pull.new(app_name, to, opts).update!
    end
  end
end
