begin
  require 'aws-sdk'
rescue LoadError
  puts "Failed to load aws-sdk gem. Please, run `gem install aws-sdk`."
end

class HasQrcode::Storage::S3
  attr_reader :active_record, :options
  
  def initialize(active_record, options)
    @active_record = active_record
    @options = options
  end
  
  def copy_to_location(from_paths)
    remove_archives if has_qrcode_before?
    
    bucket = s3_bucket
    bucket = s3.buckets.create(:name => bucket_name) unless s3_bucket.exists?
    from_paths.each do |from_path|
      key = s3_key(File.extname(from_path)[1..-1])
      bucket.objects.create(key, :file => from_path, :acl => options[:acl], :cache_control => options[:cache_control])
      FileUtils.rm_rf(from_path)
    end
  end
  
  #TODO: improve it later
  def remove_archives
    key = active_record.qrcode_filename_was
    key = "#{prefix}/#{key}" if prefix
    
    keys = ["png", "eps", "pdf"].inject([]) do |result, format|
      result << "#{key}.#{format}"
    end
    s3_bucket.objects.delete(keys)
  end
  
  def file_exist?(format)
    s3_bucket.objects[s3_key(format)].exists?
  end
  
  def generate_url(format)
    s3_bucket.objects[s3_key(format)].public_url
  end
  
  private
  def has_qrcode_before?
    active_record.qrcode_filename_was.present?
  end
  
  def has_credentials?
    options[:access_key_id] and options[:secret_access_key]
  end
  
  def prefix
    options[:prefix] || ""
  end

  def s3
    return @s3 if @s3
    
    if has_credentials?
      AWS.config(:access_key_id => options[:access_key_id], :secret_access_key => options[:secret_access_key])
    end
    @s3 = AWS::S3.new
  end
  
  def s3_bucket
    s3.buckets[options[:bucket]]
  end
  
  def s3_key(format)
    key = active_record.qrcode_filename.to_s + ".#{format}"
    "#{options[:prefix]}/#{key}"
  end
end
