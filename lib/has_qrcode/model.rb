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
      @qrcode_image_paths = HasQrcode::Processor.write_temp_file(qrcode_config.qrcode_options)
      
      # generate new filename
      self.qrcode_filename = SecureRandom.hex(16)
      
      # run this only if it is existing record. it'll run this automatically if it is new_record?
      unless new_record?
        copy_qrcode_images
        self.class.update_all({ qrcode_filename: self.qrcode_filename, updated_at: Time.now.utc }, { "#{self.class.primary_key}" => self.id })
        @qrcode_done = true
      end
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
    def copy_qrcode_images
      unless @qrcode_done
        qrcode_storage.copy_to_location(@qrcode_image_paths)
        @qrcode_done = true
      end
    end

    def qrcode_setup_if_not_exist
      qrcode_setup if qrcode_config.nil? and qrcode_storage.nil?
    end
    
    def qrcode_setup(options={})
      @qrcode_done = false
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
    def has_qrcode(options={})
      attr_reader :qrcode_config, :qrcode_storage
      class_attribute :qrcode_options
      self.qrcode_options = options
      
      self.before_save :generate_qrcode
      self.after_save  :copy_qrcode_images
    end
  end
end
