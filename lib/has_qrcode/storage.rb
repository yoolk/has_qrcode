module HasQrcode
  module Storage
    extend self
    
    def location
      return @location if @location
      self.location = :filesystem
      @location
    end
    
    def location=(location_name)
      case location_name
      when Symbol, String
        require File.join(File.dirname(__FILE__), "/storages/#{location_name}")
        @location = HasQrcode::Storage.const_get("#{location_name.to_s.camelize}")
      else
        raise "Missing storage location: #{location_name}"
      end
    end
    
    def copy_to_location(from_paths, active_record, options)
      location.copy_to_location(from_paths, active_record, options)
    end
  end
end
