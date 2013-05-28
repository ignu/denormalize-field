class DenormalizeFieldTask < Rails::Railtie
  rake_tasks do
    Dir[File.join(File.dirname(__FILE__),'lib/tasks/*.rake')].each { |f| load f }
  end
end
