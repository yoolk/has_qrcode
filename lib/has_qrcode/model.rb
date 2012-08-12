require 'active_support/concern'
require 'mini_magick'

module HasQrcode::Model
  extend ActiveSupport::Concern
  
  included do
    # available options:
    # :data     - literal string or method name as symbol
    # :size     - "250x250"
    # :margin   - "0"
    # :format   - ["png"]
    # :ecc      - "L"
    # :color    - "black"
    # :bgcolor  - "white"
    # :logo_url - logo_url
    # :backend  - :google_qr, :qr_server
    # :storage  - 
    #             :filesystem => { :path => ":rails_root/public/system/:table_name/:id.:format"}
    #             :s3 => { :bucket_name => "qr_image" }
    def generate_qrcode(options = {})
      options = self.class.qrcode_options.merge(options)
      options = merge_with_defaults(options)
      
      # extract some options out
      backend = options.delete(:backend)
      storage = options.delete(:storage)
      storage_name    = storage.try(:keys).try(:first)
      storage_options = storage.try(:values).try(:first) || {}
      
      # data
      options[:data] = process_data(options[:data])
      
      # produce result as temp file
      HasQrcode::Processor.backend = backend if backend
      qr_image_paths = HasQrcode::Processor.write_temp_file(options)
      
      # copy temp file to its final destination
      HasQrcode::Storage.location = storage_name if storage_name
      HasQrcode::Storage.copy_to_location(qr_image_paths, self, storage_options)
    end
    
    private
    def merge_with_defaults(options = {})
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
    
    def process_data(data)
      if data.is_a?(String) and data.present?
        data
      elsif data.is_a?(Symbol)
        if respond_to?(data)
          send(data)
        else
          raise RuntimeError, "#{data} is undefined. Please, define it in your model."
        end
      elsif data.blank?
        raise RuntimeError, "#{data} is blank. Please, pass it in."
      end
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
