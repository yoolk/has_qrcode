begin
  require 'aws-sdk'
rescue LoadError
  puts "Failed to load aws-sdk gem. Please, run `gem install aws-sdk`."
end

require 'secure_random'
module HasQrcode::Storage::S3
  extend self
  
  def copy_to_location(from_paths, active_record, options={})
  
    # use its own connection
    s3_config = s3_config(options[:access_key_id], options[:secret_access_key])
    
    # s3
    s3 = AWS::S3.new(:config => s3_config)
    bucket_name = options[:bucket]
    bucket      = s3.buckets[bucket_name]
    bucket      = s3.buckets.create(:name => bucket_name) unless bucket.exists?
    
    to_paths = []
    from_paths.each do |from_path|
      key    = SecureRandom.hex(16) + File.extname(from_path)
      key    = "#{options[:prefix]}/#{key}"  if options[:prefix]
      
      object = bucket.objects.create(key, :file => from_path, :acl => options[:acl], :cache_control => options[:cache_control])
      to_paths << object.public_url
    end

    to_paths
  end
  
  private
  def has_credentials?(options)
    options[:access_key_id] and options[:secret_access_key]
  end

  def s3_config(access_key_id, secret_access_key)
    if has_credentials?
      AWS.config.with(:access_key_id => access_key_id, :secret_access_key => secret_access_key)
    else
      AWS.config.credentials
    end
  end
end
