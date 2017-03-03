# encoding: utf-8
require 'active_record'

module ReplaceDataMigration
  class ReplacedataOld < ActiveRecord::Base
    self.table_name = 'replacedata'
    ENV['ENVIRONMENT'] = 'migration'
    config = YAML.load_file('../../config/database.yml')[ENV['ENVIRONMENT']]
    conn = establish_connection config
  end

  class ReplacedataNew < ActiveRecord::Base
    self.table_name = 'replacedata'
    ENV['ENVIRONMENT'] = 'development_pg'
    config = YAML.load_file('../../config/database.yml')[ENV['ENVIRONMENT']]
    conn = establish_connection config
  end

  def self.migrate
    ReplacedataOld.find_each do |old_data|
      data_hash = {}
      old_data.attributes.each do |col,val|
        data_hash[col.to_sym] = val
      end
      p "Processing data for row id #{data_hash[:id]}"
      ReplacedataNew.create!(data_hash)
    end
  end
end

ReplaceDataMigration.migrate