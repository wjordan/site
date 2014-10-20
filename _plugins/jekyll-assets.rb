# file: _plugins/jekyll-assets.rb
require "jekyll-assets"
require "image_optim"

image_optim = ImageOptim.new(
    {
        :pngquant => {:quality => 70..85},
        :jpegrecompress => {:quality => 0}
    })

%w(image/gif image/jpeg image/png image/svg+xml).each do |type|
  Sprockets.register_preprocessor type, :image_optim do |_, data|
      image_optim.optimize_image_data(data) || data
  end
end
