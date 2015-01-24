require 'sinatra/base'
require 'fastimage'

# Serve image, css and js files from /app/assets
module AssetsMapper
  class ImageController < Sinatra::Base
    configure do
      enable :inline_templates
    end

    before { @img_dir = root_join('app/assets/img') }

    # List all images under the folder (use for development)
    get('/index') do
      @images = Dir[File.join(@img_dir, '**/*.{jpg,png}')].map do |f|
        {
          id: f.sub(/#{@img_dir}\//, ''),
          size: format('%d x %d', *FastImage.size(f))
        }
      end

      slim :index
    end

    # Serve the single file with the file name
    get('/:file') { send_file(File.join(@img_dir, params[:file])) }

    get('/:dir/:file') do
      send_file(File.join(@img_dir, params[:dir], params[:file]))
    end
  end
  # Route.mount(self, '/img')
end
__END__

@@ layout
html
  head
    title = 'Image List'
  body
    == yield

@@ index
h1 = 'Image List'
pre
  code = @img_dir
hr
table
  - @images.each do |img|
    tr
      td
        image src="#{img[:id]}" width="256"
      td
        pre = "#{img[:id]}\n#{img[:size]}"
