require 'has_qrcode'

# make db connection
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", 
                                       :database => File.dirname(__FILE__) + "/activerecord_qrcode.sqlite3")
                                       
# load hooks
HasQrcode::Hooks.init

# load support files
load File.dirname(__FILE__) + '/support/schema.rb'
load File.dirname(__FILE__) + '/support/models.rb'

# overwrites
module Rails
  def self.root
    "/tmp"
  end
end

# rspec configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
