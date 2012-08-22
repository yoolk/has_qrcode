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
    # :logo     - a proc object that returns path or url of logo
    # :backend  - :google_qr, :qr_server
    # :storage  - 
    #             { :filesystem => { :path => ":rails_root/public/system/:table_name/:id/:filename.:format" } }
    #             { :s3 => { :bucket => "qr_image", :access_key_id => "ACCESS_KEY_ID", :secret_access_key => "SECRET_ACCESS_KEY", :acl => :public_read, :prefix => "", :cache_control => "max-age=28800" } }
    def generate_qrcode(options = {})
      # setup
      qrcode_setup(options)
      
      # generate to final
      temp_image_paths = HasQrcode::Processor.write_temp_file(qrcode_config.qrcode_options)
      
      # generate new filename
      self.qrcode_filename = SecureRandom.hex(16)
      
      # copy to its location
      qrcode_storage.copy_to_location(temp_image_paths)
      
      # update db
      self.class.update_all("qrcode_filename = '#{self.qrcode_filename}'", "#{self.class.primary_key} = '#{self.id}'")
      
      # run callback
      callback = self.class.after_generate
      send(callback) if callback and respond_to?(callback)
    end
    
    def qrcode_url(format)
      qrcode_setup_if_not_exist
      
      qrcode_storage.generate_url(format)
    end
    
    # check against its storage
    def qrcode_exist?(format)
      qrcode_setup_if_not_exist
      
      qrcode_storage.file_exist?(format)
    end
    
    private
    def qrcode_setup_if_not_exist
      qrcode_setup if qrcode_config.nil? and qrcode_storage.nil?
    end
    
    def qrcode_setup(options={})
      new_options = process_qrcode_options(qrcode_options.merge(options))
      @qrcode_config = HasQrcode::Configuration.new(new_options)
      HasQrcode::Processor.backend = qrcode_config.backend_name
      HasQrcode::Storage.location  = qrcode_config.storage_name
      @qrcode_storage = HasQrcode::Storage.create(self, qrcode_config.storage_options)
    end
    
    def process_qrcode_options(options)
      options.inject({}) do |result, item|
        key, value = item
        new_value = case value
        when Symbol
          self.respond_to?(value) ? self.send(value) : value.to_s
        when Proc
          value.call(self)
        else
          value
        end
        
        result[key] = new_value
        result
      end
    end
  end
  
  module ClassMethods
    def after_generate(method_name=nil)
      return @after_generate if method_name.nil?
      @after_generate = method_name
    end
    
    def has_qrcode(options={})
      attr_reader :qrcode_config, :qrcode_storage
      class_attribute :qrcode_options
      self.qrcode_options = options
      
      self.after_save :generate_qrcode
    end
  end
end
