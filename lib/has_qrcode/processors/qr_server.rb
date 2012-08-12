require 'mini_magick'
require 'tempfile'

module HasQrcode::Processor::QrServer
  extend self
  
  # TODO: decode spec
  def write_temp_file(options)
    # remove some options
    formats   = [options.delete(:format)].flatten
    logo_url  = options.delete(:logo_url)
    
    # generate image from qr_server
    qr_server = QrServer.new(options)
    qr_image  = MiniMagick::Image.open(qr_server.to_s)
    qr_image  = embed_logo(qr_image, logo_url, qr_server.bgcolor) if logo_url
    
    # write images into multiple formats
    qr_image_paths = []
    formats.each do |format|
      qr_image_paths << write_image(qr_image, format)
    end
    qr_image_paths
  end
  
  private
  def write_image(image, format)
    image_path = Tempfile.new(%W[qr_server .#{format}]).path
    image.format format
    image.write  image_path
    
    image_path
  end
  
  def embed_logo(qr_image, logo_url, bgcolor)

    # resize logo
    logo_size = (qr_image[:width] / 6)
    logo_image = MiniMagick::Image.open(logo_path)
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
