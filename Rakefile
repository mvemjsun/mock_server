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
    env_migration_version = ENV['VERSION'] || '1'
    p "Migration version #{env_migration_version}"
    ActiveRecord::MigrationContext.new("./db/migrations").migrate(env_migration_version.to_i)
  end
end
