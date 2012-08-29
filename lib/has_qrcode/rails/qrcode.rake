namespace :qrcode do
  task :require => [:environment] do
    begin
      require 'progress_bar'
    rescue LoadError
      puts "Failed to load progress_bar gem. Please, run `gem install progress_bar`."
    end
  end
  
  desc "Generate qrcode image on a specified model"
  task :generate, [:model_name, :scope_name, :scope_value] => [ 'qrcode:require'] do |t, args|
    model_name, scope_name, scope_value = args.model_name, args.scope_name, args.scope_value
    
    raise "Model '#{model_name}' is missing." if model_name.blank?
    model = Object.const_get(model_name)
    
    scoped = if scope_name.blank?
      model
    elsif model.respond_to?(scope_name)
      model.send(scope_name, scope_value)
    else
      raise "Scope '#{scope_name}' does not exist in your model."
    end
    
    pbar = ProgressBar.new(scoped.count)
    scoped.find_each do |record|
      begin
        record.generate_qrcode
      rescue => e
        puts "#{e} for #{record.class.name}: #{record.id}"
      end
      pbar.increment!
    end
  end
end
