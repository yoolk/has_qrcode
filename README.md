# HasQrcode

This gem provides qrcode support to your active_record models. It allows people to generate qrcode images and store them on filesystem or s3. It uses `mini_magick` gem as its dependency. This means that you must install ImageMagick on your system.

## Installation

Add this line to your application's Gemfile:

    gem 'has_qrcode'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install has_qrcode

## Usage

In your model:

    class Article < ActiveRecord::Base
      has_qrcode   :data    => :to_vcard,      # required
                   :logo    => :logo_url,      # optional
                   :size    => "250x250",      # optional, default is "250x250"
                   :margin  => "5",            # optional, default is "0"
                   :format  => ["png", "eps"], # optional, default is "png"
                   :ecc     => "L",            # optional, default is "L"
                   :bgcolor => "fff",          # optional, default is "fff"
                   :color   => "000",          # optional, default is "000"
                   :processor => :qr_server    # optional, default is :qr_server for now (might be changed in the future)
                   :storage => { :filesystem => { :path => ":rails_root/public/system/:table_name/:id/:filename.:format" } }
    end

In your migrations:

    class AddQrCodeToArticle < ActiveRecord::Migration
      def change
        add_column :articles, :qrcode_filename, :string
      end
    end

In your show view:

    <%= image_tag @article.qrcode_url(:png) %>

In your rails console:

    Article.first.generate_qrcode!
    
### HasQrcode Options

By default, all has_qrcode options are evaluated at runtime on instance object level so that it can be dynamically for each instance. You can specify the value as `symbol` or a `proc` object.

To generate qrcode image for any record, just call `generate_qrcode`. When you call it without any arguments, it will use options from `has_qrcode`. You can call it with different options from `has_qrcode`, and it won't affect your model `has_qrcode` options.

HasQrcode will add `after_save` callback to generate qrcode image after the record is saved.

### Processor

Currently, HasQrcode supports only one processor which connects to the [QR-Server API](http://qrserver.com/api/documentation/).

    has_qrcode :processor => :qr_server

### Storage

HasQrcode ships with 2 storage adapters:

* File Storage
* S3 Storage (via `aws-sdk`)
    
The image files that are generated, by default, placed in the directory specified by the `:storage` option to `has_qrcode`. By default, on :filesystem the location is `:rails_root/public/system/:table_name/:id/:filename.:format`.

    has_qrcode  :storage => { :filesystem => { :path => ":rails_root/public/system/:table_name/:id/:filename.:format" } }

You may also choose to store your files using Amazon's S3 service. To do so, include the aws-sdk gem in your Gemfile:

    gem 'aws-sdk', '~> 1.3.4'

And then you can specify using S3 from has_qrcode.

    has_qrcode  :storage => { :s3 => { :bucket => "qrcode-images", :prefix => "kh", :acl => :public_read, :cache_control => "max-age=28800" } }
    
You can pass the aws credentials: `access_key_id` and `secret_access_key` in the storage options here or create `aws.yml` file in your `config` directory.
    
By default, the qrcode_filename is generated randomly using the standard ruby library [SecureRandom](http://rubydoc.info/stdlib/securerandom/1.9.3/SecureRandom).

### Rake Script

This gem provides one rake script to generate qrcode images for a specified model.

    $ rake qrcode:generate[model_name,scope_name,scope_value]
    $ rake qrcode:generate[Article,by_author,Chamnap] # generate qrcode images for Article posted by author, Chamnap.
    
### Testing

In your rails application in test environment, add `stub_request: true` in your `config/aws.yml` on `test:` section so that it won't send any real requests to amazon.

To turn off the callback that generates qrcode images, call one of the followings in your spec support helper.

  - Listing.skip_callback(:save, :after, :generate_qrcode)
  - Listing.reset_callbacks(:save)
    
### TODO
- Add more specs
- Support `rqrcode` processor and `google-qr`
- Support multiple sizes
- Refactor code
