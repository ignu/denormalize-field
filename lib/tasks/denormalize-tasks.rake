namespace :denormalize do
  task :show_outdated do
    DenormalizeFields::CLASSES.each do |klass|
      p "Out of sync for #{klass.name}: #{klass.out_of_sync.count}"
    end
  end

  task :sync do
    DenormalizeUpdater.sync_all
  end
end
