require 'spec_helper'

describe "should write image based on format", :pending do
  before(:all) do
    FileUtils.rm_rf("/tmp/hello_world.eps")
    FileUtils.rm_rf("/tmp/hello_world.pdf")
    @qr_server = QrServer.new(:data => VCARD_DATA)
  end
  
  it "eps format" do
    @qr_server.eps("/tmp", "hello_world")

    File.exist?("/tmp/hello_world.eps").should eq(true)
  end
  
  it "pdf format" do
    @qr_server.pdf("/tmp", "hello_world")  
    
    File.exist?("/tmp/hello_world.pdf").should eq(true)
  end
end
