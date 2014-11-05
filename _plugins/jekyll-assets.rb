# file: _plugins/jekyll-assets.rb
require "jekyll-assets"

require 'sprockets-webp'
Sprockets::WebP.encode_options = { quality: 80, lossless: 0, method: 6, alpha_filtering: 2, alpha_compression: 0, alpha_quality: 100 }

%w(image/jpeg image/png).each do |type|
  Sprockets.register_preprocessor type, :webp do |context, data|
    Tempfile.open('webp-in') do |in_file|
      in_file.binmode
      in_file.write(data)
      in_file.close

      # WebP File Pathname
      webp_base = File.join(context.environment.root, '.jekyll-assets-cache', 'webp')
      out_file = File.join(webp_base, 'assets', "#{context.logical_path}.webp")
      # Create Directory for output file unless already exists
      FileUtils.mkdir_p(File.dirname(out_file)) unless Dir.exists?(File.dirname(out_file))
      ::WebP.encode(in_file.path, out_file.to_s, Sprockets::WebP.encode_options)
      puts "Preprocessor: input size=#{data.length}"
    end
    data
  end

  Sprockets.register_postprocessor type, :webp do |context, data|
    env = context.environment
    site = context.site
    webp_base = File.join(env.root, '.jekyll-assets-cache', 'webp')
    out_file = File.join(webp_base, 'assets', "#{context.logical_path}.webp")
    digest = env.digest.update(data).hexdigest
    filename = "#{File.basename(out_file, '.webp')}-#{digest}.webp"
    new_out_file = ::Jekyll::StaticFile.new(site, webp_base, 'assets', filename)
    FileUtils.mv(out_file, new_out_file.path)
    site.static_files << new_out_file
    puts "Postprocessor : processed size=#{data.length}, webp size=#{File.size(new_out_file.path)}"
    data
  end
end

require "image_optim"
image_optim = ImageOptim.new(
    {
        :pngquant => {:quality => 70..85},
        :jpegrecompress => {:quality => 0},
        :jpegoptim => {:max_quality => 90}
    })

%w(image/gif image/jpeg image/png image/svg+xml).each do |type|
  Sprockets.register_preprocessor type, "image_optim_#{type}".to_sym do |context, data|
    image_optim.optimize_image_data(data) || data
  end
end

module Jekyll
  module AssetsPlugin
    class Renderer
      WEBP = <<html
<picture>
  <source srcset="%{path_webp}" type="image/webp">
	<img srcset="%{path}">
</picture>
html
      def path_webp(path)
        path.chomp(File.extname(path)) + '.webp'
      end

      def render_image_data
        return format(IMAGE, :path => path, :attrs => attrs) if remote?
        asset = site.assets[path]
        base64 = Base64.encode64(asset.to_s).gsub(/\s+/, "")
        base64_string = "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
        format IMAGE, :path => base64_string, :attrs => attrs
      end

      def render_webp
        return format(WEBP, :path => path, :attrs => attrs, :path_webp => path_webp(path)) if remote?
        asset = site.assets[path]
        tags  = (site.assets_config.debug ? asset.to_a : [asset]).map do |a|
          asset_path = AssetPath.new(a).to_s
          format WEBP, :path => asset_path, :attrs => attrs, :path_webp => path_webp(asset_path)
        end
        tags.join "\n"
      end
    end
  end
end

Liquid::Template.register_tag :webp, Jekyll::AssetsPlugin::Tag
Liquid::Template.register_tag :image_data, Jekyll::AssetsPlugin::Tag

module SitePatch
  def self.included(base)
    base.class_eval do
      alias_method :__orig_write_2, :write
      alias_method :write, :__wrap_write_2
    end
  end
  def __wrap_write_2
    asset_files.each do |asset_file|
      root = asset_file.instance_variable_get(:@root)
      webp_base = File.join(root, '.jekyll-assets-cache', 'webp')
      filename = asset_file.digest_path
      filename = filename.chomp(File.extname(filename)) + '.webp'
      new_out_file = ::Jekyll::StaticFile.new(asset_file.site, webp_base, 'assets', filename)
      exists = File.exist?(new_out_file.path)
      static_files << new_out_file if exists
    end
    __orig_write_2
  end
end
Jekyll::Site.send :include, SitePatch

# Serve custom mime types
module ServePatch
  def self.included(base)
    base.instance_eval do
      def mime_types
        WEBrick::HTTPUtils::load_mime_types('mime.types')
      end
    end
  end
end
Jekyll::Commands::Serve.send :include, ServePatch
