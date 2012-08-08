namespace :qrcode do
  desc "Generate qrcode image on a specified model"
  task :generate, [:model_name] => :environment do |t, args|
    model = Object.const_get(args.model_name)
    model.find_each do |record|
      record.generate_qrcode
    end
  end
end
