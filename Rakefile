# frozen_string_literal: true

require 'rake/testtask'

task default: [:spec]

desc 'List all Rake tasks'
task :tasks do
  sh 'rake -T'
end

desc 'Tests API specs only'
task :api_spec do
  sh 'ruby specs/api_spec.rb'
end

desc 'Run all the tests'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'specs/*_spec.rb'
  t.warning = false
end

desc 'Runs rubocop on tested code'
task style: [:spec] do
  sh 'rubocop **/*.rb'
end

task :print_env do
  puts "Environment: #{ENV['RACK_ENV'] || 'development'}"
end

desc 'Run application console (pry)'
task :console => :print_env do
  sh 'pry -r ./specs/test_load_all'
end

desc 'Run application in development mode and port'
task :run_dev do
  sh 'rerun -c "rackup -p 3000"'
end

namespace :db do
  require_relative 'lib/init' # load libraries
  require_relative 'config/init' # load config info
  app = Credence::Api

  task :setup do
    require 'sequel'
    Sequel.extension :migration
  end

  task :load_models do
    require_relative 'models/init'
    require_relative 'services/init'
  end

  desc 'Run migrations'
  task :migrate => [:setup, :print_env] do
    puts 'Migrating database to latest'
    Sequel::Migrator.run(app.DB, 'db/migrations')
  end

  desc 'Delete dev or test database file'
  task :drop do
    if app.environment == :production
      puts 'Cannot wipe production database!'
      return
    end

    FileUtils.rm(app.config.DB_FILENAME)
    puts "Deleted #{app.config.DB_FILENAME}"
  end

  desc 'Delete and migrate again'
  task reset: [:drop, :migrate]

  task :reset_seeds => [:setup, :load_models] do
    app.DB[:schema_seeds].delete if app.DB.tables.include?(:schema_seeds)
    Credence::Account.dataset.destroy
  end

  desc 'Seeds the development database'
  task :seed => [:setup, :print_env, :load_models] do
    require 'sequel/extensions/seed'
    Sequel::Seed.setup(:development)
    Sequel.extension :seed
    Sequel::Seeder.apply(app.DB, 'db/seeds')
  end

  desc 'Delete all data and reseed'
  task reseed: [:reset_seeds, :seed]
end

namespace :generate do
  task :load_secure_lib do
    require_relative 'models/init'
    require_relative 'services/init'
  end

  desc 'Create sample cryptographic key for database'
  task :db_key do
    require './lib/secure_db'
    puts "DB_KEY: #{SecureDB.generate_key}"
  end

  desc 'Create sample cryptographic key for tokens and messaging'
  task :msg_key do
    require './lib/auth_token'
    puts "MSG_KEY: #{SecureDB.generate_key}"
  end

  desc 'Create sample private/public keypair for signed communication'
  task :signing_keypair do
    require './lib/signed_request'
    keypair = SignedRequest.generate_keypair

    puts "SIGNING_KEY: #{keypair[:signing_key]}"
    puts " VERIFY_KEY: #{keypair[:verify_key]}"
  end
end
