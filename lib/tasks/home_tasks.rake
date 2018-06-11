require 'fileutils'

namespace :home do
  desc "Create demo user"
  task install: [:environment] do

    Rake::Task["home_engine:install:migrations"].invoke
    Rake::Task["db:migrate"].invoke

    Home::Engine.load_seed

    path = Home.custom_behavior_path
    unless File.directory?(path)
      puts "Creating folder #{ path }"
      FileUtils.mkdir_p(path)
    end

    path = Rails.root.join('app', 'assets', 'images', 'entities')
    unless File.directory?(path)
      puts "Creating folder #{ path }"
      FileUtils.mkdir_p(path)
    end

    initializers_from = Home::Engine.root.join('lib', 'tasks', 'initializers', '*')
    initializers_to = Rails.root.join('config', 'initializers')
    Dir.glob(initializers_from) do |file|
      FileUtils.cp(file, initializers_to)
      puts "See #{ initializers_to.join(File.basename(file)) } to configure Home On Rails"
    end

  end

end
