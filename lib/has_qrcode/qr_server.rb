require 'uri'
require 'active_support'
require 'tempfile'

class QrServer
  attr_accessor   :size, :margin, :format, :bgcolor, :color, :ecc,
                  :charset_target, :charset_source, :qzone
  attr_reader     :data
  BASE_URI = "http://api.qrserver.com/v1/create-qr-code/?"
  
  def initialize(options = {})    
    options.each_pair do |key, value|
      send("#{key}=".to_sym, value)
    end
  end
  
  def to_s
    validate_options!
    
    queries = to_hash.sort.collect { |k, v| "#{k}=#{v}" }.join("&")
    BASE_URI + queries 
  end
  
  def data=(data)
    @data = escape_string(data)
  end
  
  def to_hash
    instance_variables.inject({}) do |result, variable|
      variable = variable.to_s.gsub("@", "").to_sym
      result[variable] = instance_variable_get("@#{variable}".to_sym)
      
      result
    end
  end
  
  private
  #TODO: refactor to use our own class exception
  def validate_options!
    raise RuntimeError if data.blank?
    raise RuntimeError if margin.present? and !margin.to_i.between?(0, 50)
    raise RuntimeError if ecc.present? and !["L", "M", "Q", "H"].include?(ecc)
    
    if size.present?
      width, height = size.split("x").collect(&:to_i)
      raise RuntimeError if width != height
      raise RuntimeError unless width.between?(10, 1000)
    end
  end
  
  def escape_string(string)
    URI.encode(string.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end
end
