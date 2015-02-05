require 'sinatra/base'
require 'fastimage'
require 'asset_settings'

# serve js/css files from local `app/assets` folder
class ImageController < Sinatra::Base
  configure { enable :inline_templates }
  before { @img_dir = AssetSettings.get.img_dir }

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
  get(%r{\/([\w\/\-\.]+)}) { |f| send_file(File.join(@img_dir, f)) }

  # load assets controllers
  unless AssetSettings.production?
    Route.mount(self, AssetSettings.get.img_url_prefix)
  end
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
