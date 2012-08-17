require 'mini_magick'
require 'tempfile'
require 'has_qrcode/qr_server'

module HasQrcode::Processor::QrServer
  extend self
  
  def write_temp_file(options)
  
    # remove some options
    options = options.dup
    formats = [options.delete(:format)].flatten
    logo    = options.delete(:logo)
    
    # generate image from qr_server
    qr_server = QrServer.new(options)
    qr_image  = MiniMagick::Image.open(qr_server.to_s, ".png")
    qr_image  = embed_logo(qr_image, logo, qr_server.bgcolor) if logo
    qr_image.format "png"
    
    # qrcode image paths
    qr_paths  = []
    qr_paths  << qr_image.path
    
    other_formats = formats.delete_if { |format| format == "png" }
    other_formats.each do |format|
      qr_paths << convert_image(qr_image.path, format)
    end
    
    qr_paths
  end
  
  private
  def convert_image(image_path, format)
    `mogrify -format #{format} #{image_path}`
    image_path.gsub(/#{File.extname(image_path)}$/, ".#{format}")
  end
  
  def embed_logo(qr_image, logo, bgcolor)

    # resize logo
    logo_size = (qr_image[:width] / 6)
    logo_image = MiniMagick::Image.open(logo)
    logo_image.resize "#{logo_size}x#{logo_size}"
    
    # create background_image, composite with logo
    bg_image = new_image(logo_size+5, logo_size+5, "png", bgcolor)
    logo_bg_image = composite_center(bg_image, logo_image)
    
    # composite with qr_image
    composite_center(qr_image, logo_bg_image)
  end
  
  def composite_center(original_image, embed_image)
    original_image.composite(embed_image) do |c|
      c.gravity "center"
    end
  end
  
  def new_image(width, height, format = "png", bgcolor = "transparent")
    tmp = Tempfile.new(%W[mini_magick_ .#{format}])
    `convert -size #{width}x#{height} xc:##{bgcolor} #{tmp.path}`
    MiniMagick::Image.new(tmp.path, tmp)
  end
end
