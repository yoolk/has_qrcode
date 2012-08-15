require 'fileutils'

class HasQrcode::Storage::Filesystem

  attr_reader :active_record, :options
  def initialize(active_record, options)
    @active_record = active_record
    @options = options
  end
  
  def copy_to_location(from_paths)
    remove_archives
    
    from_paths.each do |from_path|
      to_path = generate_to_path(path, active_record, :format => File.extname(from_path)[1..-1], :filename => active_record.qrcode_filename)
      
      FileUtils.mkdir_p(File.dirname(to_path))
      FileUtils.mv(from_path, to_path, :force => true)
    end
  end
  
  def remove_archives
    file_path = generate_to_path(path, active_record, :filename => active_record.qrcode_filename_was, :format => "*")
    FileUtils.rm_rf Dir.glob(file_path)
  end
  
  def generate_url(format)
    generate_to_path(path, active_record, :format => format, :filename => active_record.qrcode_filename, :rails_root => "")
  end
  
  private
  def path
    options[:path] || ":rails_root/public/system/:table_name/:id/:filename.:format"
  end
  
  def generate_to_path(path, active_record, values)
    default_values = {
      :rails_root => Rails.root
    }
    values = default_values.merge(values)
    
    generated_path = path.clone
    segments = path.scan(/:\w+/)
    segments.each do |key|
      key = key[1..-1].to_sym
      value = if active_record.respond_to?(key)
        active_record.send(key)
      elsif active_record.class.respond_to?(key)
        active_record.class.send(key)
      else
        values[key]
      end

      generated_path.gsub!(/:#{key}/, value.to_s)
    end

    generated_path
  end
end

