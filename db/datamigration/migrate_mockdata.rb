# encoding: utf-8
require 'active_record'

module MockDataMigration
  class MockdataOld < ActiveRecord::Base
    self.table_name = 'mockdata'
    ENV['ENVIRONMENT'] = 'migration'
    config = YAML.load_file('../../config/database.yml')[ENV['ENVIRONMENT']]
    conn = establish_connection config
  end

  class MockdataNew < ActiveRecord::Base
    self.table_name = 'mockdata'
    ENV['ENVIRONMENT'] = 'development_pg'
    config = YAML.load_file('../../config/database.yml')[ENV['ENVIRONMENT']]
    conn = establish_connection config
  end

  def self.migrate
    MockdataOld.find_each do |old_data|
      data_hash = {}
      old_data.attributes.each do |col,val|
        data_hash[col.to_sym] = val
      end
      p "Processing data for row id #{data_hash[:id]}"
      MockdataNew.create!(data_hash)
    end
  end
end

MockDataMigration.migrate