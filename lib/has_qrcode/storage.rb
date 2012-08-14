module HasQrcode
  class Storage
    def self.location
      return @location if @location
      self.location = :filesystem
      @location
    end
    
    def self.location=(location_name)
      case location_name
      when Symbol, String
        require File.join(File.dirname(__FILE__), "/storages/#{location_name}")
        @location = HasQrcode::Storage.const_get("#{location_name.to_s.camelize}")
      else
        raise "Missing storage location: #{location_name}"
      end
    end
    
    def self.create(active_record, options)
      location.new(active_record, options)
    end
  end
end
