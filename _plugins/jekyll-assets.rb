# file: _plugins/jekyll-assets.rb
require 'jekyll-assets'
require 'image_optim'
image_optim = ImageOptim.new(
  {
    :allow_lossy => true,
    :svgo => false,
    :pngout => false,
    :pngquant => {:quality => 70..85},
    :jpegrecompress => {:quality => 0},
    :jpegoptim => {:max_quality => 90}
  })

%w(image/gif image/jpeg image/png image/svg+xml).each do |type|
  Sprockets.register_preprocessor type, "image_optim_#{type}".to_sym do |context, data|
    image_optim.optimize_image_data(data) || data
  end
end
