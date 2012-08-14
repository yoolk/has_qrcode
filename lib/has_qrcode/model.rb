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
    # :logo     - path or url of logo
    # :backend  - :google_qr, :qr_server
    # :storage  - 
    #             :filesystem => { :path => ":rails_root/public/system/:table_name/:id.:format" }
    #             :s3 => { :bucket => "qr_image", :access_key_id => "ACCESS_KEY_ID", :secret_access_key => "SECRET_ACCESS_KEY", :acl => :public_read, :prefix => "", :cache_control => "max-age=28800" }
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
      
      # 1. produce result as temp file
      HasQrcode::Processor.backend = backend if backend
      temp_image_paths = HasQrcode::Processor.write_temp_file(options)
      
      # 2. Assign storage
      # 3. remove old images
      # 4. copy temp file to its final destination
      self.qrcode_filename = SecureRandom.hex(16)
      HasQrcode::Storage.location = storage_name if storage_name
      storage = HasQrcode::Storage.create(self, storage_options)
      storage.copy_to_location(temp_image_paths)
      
      # 4. run callback
      callback = self.class.after_generate
      send(callback) if callback and respond_to?(callback)
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
        raise RuntimeError, ":data is blank. Please, pass it in."
      end
    end
  end
  
  module ClassMethods
    def after_generate(method_name=nil)
      return @after_generate if method_name.nil?
      @after_generate = method_name
    end
    
    def has_qrcode(options={})
      @options = options
      
      self.after_save :generate_qrcode
    end
    
    def qrcode_options
      @options || {}
    end
  end
end
