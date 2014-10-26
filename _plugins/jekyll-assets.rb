# file: _plugins/jekyll-assets.rb
require "jekyll-assets"
require "image_optim"

image_optim = ImageOptim.new(
    {
        :pngquant => {:quality => 70..85},
        :jpegrecompress => {:quality => 0},
        :jpegoptim => {:max_quality => 90}
    })

require 'sprockets-webp'
Sprockets::WebP.encode_options = { quality: 80, lossless: 0, method: 6, alpha_filtering: 2, alpha_compression: 0, alpha_quality: 100 }

%w(image/jpg image/jpeg image/png).each do |type|
  Sprockets.register_preprocessor type, :webp do |context, data|
    environment = context.environment
    site = context.site
    Tempfile.open('webp-in') do |in_file|
      in_file.binmode
      in_file.write(data)
      in_file.close

      # WebP File Pathname
      filename = "#{context.logical_path}-#{environment.file_digest(context.pathname)}.webp"
      webp_base = File.join(environment.root, '.jekyll_assets_cache', 'webp')
      out_file = File.join(webp_base, 'assets', filename)
      # Create Directory for output file unless already exists
      FileUtils.mkdir_p(File.dirname(out_file)) unless Dir.exists?(File.dirname(out_file))
      ::WebP.encode(in_file.path, out_file.to_s, Sprockets::WebP.encode_options)
      puts "input size=#{data.length}, webp size=#{File.size(out_file)}"
      site.static_files << ::Jekyll::StaticFile.new(site, webp_base, 'assets', filename)
    end
    data
  end
end

%w(image/gif image/jpeg image/png image/svg+xml).each do |type|
  Sprockets.register_preprocessor type, "image_optim_#{type}".to_sym do |context, data|
    puts "image_optim, context=#{context.logical_path}"
    image_optim.optimize_image_data(data) || data
  end
end
