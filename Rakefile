require 'active_record'
require 'yaml'
require 'logger'
require 'cucumber/rake/task'
require 'sqlite3'
require 'zlib'

ENV['ENVIRONMENT'] ||= 'development'

namespace :db do
  def create_my_database
    p 'Create DB'
  end

  task :configure do
    p 'Task Reading configuration ...'
    @config = YAML.load_file('config/database.yml')[ENV['ENVIRONMENT']]
  end

  task :connect_to_db do
    p 'Task Establishing connection ...'
    p @config.inspect
    ActiveRecord::Base.establish_connection @config
    ActiveRecord::Base.logger = Logger.new(File.open('logs/migrations.log', 'a'))
  end

  task :migrate => [:configure, :connect_to_db] do
    p 'Task Migrate ...'
    ActiveRecord::Migration.verbose = true
    x = ENV['VERSION'] || '1'
    p "Migration version #{x}"
    ActiveRecord::Migrator.migrate './db/migrations', ENV['VERSION'] ? ENV['VERSION'].to_i : nil
  end

  task :rollback => [:configure, :connect_to_db] do
    # Default rollback to 1 step if STEP not specified in rake command
    rollback_steps = ENV['STEPS'] ? ENV['STEPS'].to_i : 1
    p "Rollback by #{rollback_steps} step(s)"
    ActiveRecord::Migrator.rollback './db/migrations', rollback_steps
  end

  task :prepare => [:configure, :connect_to_db] do
    p 'Populating initial data.'
    # make_users
  end
end
