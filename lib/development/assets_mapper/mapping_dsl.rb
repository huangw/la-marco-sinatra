require_relative 'pull'
# mix-in the name space
module AssetsMapper
  # DSL command available directly in the mapping ruby file, top scope
  module MappingDSL
    def pull(app_name, opts)
      to = opts.extract_args(to: pull_dir)
      Pull.new(app_name, to, opts).update!
    end
  end
end
