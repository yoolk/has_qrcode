require 'uri'
require 'active_support'
require 'tempfile'

class QrServer
  attr_accessor   :size, :margin, :format, :bgcolor, :color, :ecc,
                  :charset_target, :charset_source, :qzone
  attr_reader     :data
  BASE_URI = "http://api.qrserver.com/v1/create-qr-code/?"
  
  def initialize(options = {})    
    options.each_pair do |key, value|
      send("#{key}=".to_sym, value)
    end
  end
  
  def to_s
    validate_options!
    
    queries = to_hash.sort.collect { |k, v| "#{k}=#{v}" }.join("&")
    BASE_URI + queries 
  end
  
  def data=(data)
    @data = escape_string(data)
  end
  
  def to_hash
    instance_variables.inject({}) do |result, variable|
      variable = variable.to_s.gsub("@", "").to_sym
      result[variable] = instance_variable_get("@#{variable}".to_sym)
      
      result
    end
  end
  
  def eps(path, file_name)
    FileUtils.mkdir_p(path)
    
    image = MiniMagick::Image.open(to_s)
    image.format "eps"
    image.write  File.join(path, "#{file_name}.eps")
  end
  
  def pdf(path, file_name)
    FileUtils.mkdir_p(path)
    
    image = MiniMagick::Image.open(to_s)
    image.format "pdf"
    image.write  File.join(path, "#{file_name}.pdf")
  end
  
  # TODO: decode spec
  def embed_logo(path, file_name, logo_path)
    qr_image = MiniMagick::Image.open(to_s)
    
    # resize logo
    logo_size = (qr_image[:width].to_f / 6).ceil
    logo_image = MiniMagick::Image.open(logo_path)
    logo_image.resize "#{logo_size-6}x#{logo_size-6}"
    
    # create background_image, composite with logo
    bg_image = new_image(logo_size, logo_size, "png", bgcolor)
    logo_bg_image = bg_image.composite(logo_image) do |c|
      c.gravity "center"
    end
    
    # composite with qr_image
    result = qr_image.composite(logo_bg_image) do |c|
      c.gravity "center"
    end
    result.write File.join(path, "#{file_name}.#{format}")
  end
  
  private
  def new_image(width, height, format = "png", bgcolor = "transparent")
    tmp = Tempfile.new(%W[mini_magick_ .#{format}])
    `convert -size #{width}x#{height} xc:#{bgcolor} #{tmp.path}`
    MiniMagick::Image.new(tmp.path, tmp)
  end
  
  #TODO: refactor to use our own class exception
  def validate_options!
    raise RuntimeError if data.blank?
    raise RuntimeError if margin.present? and !margin.to_i.between?(0, 50)
    raise RuntimeError if ecc.present? and !["L", "M", "Q", "H"].include?(ecc)
    
    if size.present?
      width, height = size.split("x").collect(&:to_i)
      raise RuntimeError if width != height
      raise RuntimeError unless width.between?(10, 1000)
    end
  end
  
  def escape_string(string)
    URI.encode(string.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end
end
