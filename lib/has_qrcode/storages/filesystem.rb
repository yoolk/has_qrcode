require 'fileutils'

module HasQrcode::Storage::Filesystem
  extend self
  
  def copy_to_location(from_paths, active_record, options={})
    path_pattern = options[:path] || ":rails_root/public/system/:table_name/:id/:id.:format"
    
    to_paths = []
    from_paths.each do |from_path|
      to_paths << generate_to_path(path_pattern, File.extname(from_path)[1..-1], active_record)
      
      FileUtils.mkdir_p(File.dirname(to_paths.last))
      FileUtils.mv(from_path, to_paths.last, :force => true)
    end
    to_paths
  end
  
  private
  def generate_to_path(pattern, format, active_record)
    default_values = {
      :rails_root => Rails.root,
      :format     => format
    }
    
    path = pattern.clone
    pattern.scan(/:\w+/) do |key|
      key = key[1..-1].to_sym
      value = if active_record.respond_to?(key)
        active_record.send(key)
      elsif active_record.class.respond_to?(key)
        active_record.class.send(key)
      else
        default_values[key]
      end

      path.gsub!(/:#{key}/, value.to_s)
    end

    path
  end
end

