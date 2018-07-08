namespace :db do
  desc "Recreate database"
  task recreate: :environment do
    Rake::Task["db:environment:set"].invoke
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
  end

end