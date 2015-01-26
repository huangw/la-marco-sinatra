# produce a file
class Producer
  attr_reader :file_type
  def initialize(file_id, opts = {})
    @file_id = file_id
    @file_type = opts.extract_args(type: file_id.scan(/\.(css|js)\Z/))
    d_as = File.join(AssetsSettings[:production].min_dir, file_id)
    @minimize_as = opts.extract_args!(minimize_as: d_as)
  end
end
