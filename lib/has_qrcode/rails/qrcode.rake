namespace :qrcode do
  task :require do
    begin
      require 'progressbar'
    rescue LoadError
      puts "Failed to load progressbar gem. Please, run `gem install progressbar`."
    end
  end
  
  desc "Generate qrcode image on a specified model"
  task :generate, [:model_name, :scope_name, :scope_value] => [ 'qrcode:require', :environment] do |t, args|
    model_name, scope_name, scope_value = args.model_name, args.scope_name, args.scope_value
    
    raise "Model '#{model_name}' is missing." if model_name.blank?
    model = Object.const_get(model_name)
    
    pbar = ProgressBar.new("Generating", (model.count/1000).ceil)
    scoped = if scope_name.blank?
      model
    elsif model.respond_to?(scope_name)
      model.send(scope_name, scope_value)
    else
      raise "Scope '#{scope_name}' does not exist in your model."
    end

    scoped.find_in_batches do |records|
      records.each(&:generate_qrcode)
      pbar.inc
    end
    
    pbar.finish
  end
end
