# encoding: utf-8
require 'active_record'

module RubyscriptDataMigration
  class RubyscriptOld < ActiveRecord::Base
    self.table_name = 'rubyscripts'
    ENV['ENVIRONMENT'] = 'migration'
    config = YAML.load_file('../../config/database.yml')[ENV['ENVIRONMENT']]
    conn = establish_connection config
  end

  class RubyscriptNew < ActiveRecord::Base
    self.table_name = 'rubyscripts'
    ENV['ENVIRONMENT'] = 'development_pg'
    config = YAML.load_file('../../config/database.yml')[ENV['ENVIRONMENT']]
    conn = establish_connection config
  end

  def self.migrate
    RubyscriptOld.find_each do |old_data|
      data_hash = {}
      old_data.attributes.each do |col,val|
        data_hash[col.to_sym] = val
      end
      p "Processing data for row id #{data_hash[:id]}"
      RubyscriptNew.create!(data_hash)
    end
  end
end

RubyscriptDataMigration.migrate