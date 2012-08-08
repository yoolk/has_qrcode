require 'active_support/concern'
require 'mini_magick'

module HasQrcode::Model
  extend ActiveSupport::Concern
  
  included do
    # available options:
    # :path     - ":rails_root/public/system/:table_name/:id.:format"
    # :data     - any string to encode
    # :data_method - method that returns data to encode
    # :size     - "250x250"
    # :margin   - "0"
    # :format   - "png"
    # :ecc      - "L"
    # :color    - "black"
    # :bgcolor  - "white"
    def generate_qrcode(options = {})
      options = self.class.qrcode_options.merge(options)
      options = default_options(options)
      
      # generate_path
      filepath_pattern = options.delete(:path) || ":rails_root/public/system/:table_name/:id.:format"
      path = generate_path(filepath_pattern, {
        :rails_root => Rails.root, 
        :table_name => self.class.table_name,
        :id         => self.id.to_s, 
        :format     => options[:format]
      })
      
      # generate_data
      data_method = options.delete(:data_method)
      if data_method and respond_to?(data_method) and options[:data].blank?
        options[:data] = send(data_method)
      elsif options[:data].blank?
        raise RuntimeError, "#{data_method} is undefined. Please, define it accordingly."
      end
      
      qr = QrServer.new(options)
      write_image_from_remote(qr.to_s, path)
      path
    end
    
    private
    def default_options(options = {})
      defaults = {
        :size     => "250x250",
        :margin   => 0,
        :ecc      => "L",
        :color    => "000",
        :bgcolor  => "fff",
        :format   => "png"
      }
      defaults.merge(options)
    end
    
    def generate_path(pattern, values = {})
      values.each_pair do |key, value|
        pattern = pattern.gsub(/:#{key}/, value.to_s)
      end
      
      pattern
    end
    
    def write_image_from_remote(url, path_to_write)
      image = MiniMagick::Image.open(url)
      FileUtils.mkdir_p(File.dirname(path_to_write))
      image.write(path_to_write)
    end
  end
  
  module ClassMethods
    def has_qrcode(options={})
      @options = options
      
      self.after_save :generate_qrcode
    end
    
    def qrcode_options
      @options || {}
    end
  end
end
