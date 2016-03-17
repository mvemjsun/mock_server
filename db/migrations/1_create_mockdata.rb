class CreateMockdata < ActiveRecord::Migration

  def self.up

    create_table :mockdata do |t|
      t.string :mock_name
      t.string :mock_http_status
      t.text :mock_request_url
      t.string :mock_data_response_headers
      t.text   :mock_data_response, limit: 1000000
      t.boolean :mock_state
      t.string :mock_environment
      t.string :mock_content_type
      t.integer :mock_served_times
      t.timestamps
    end

    # add_index :mockdata, [:mock_request_url, :mock_environment, :mock_state], :unique => true, name: 'unique_data'
    execute <<-SQL
      CREATE UNIQUE INDEX "unique_mock_data"
      ON "MOCKDATA" ("mock_request_url", "mock_environment", "mock_state")
      WHERE "mock_state" = 't'
    SQL

    create_table :missed_requests do |t|
      t.string :url
      t.string :mock_environment
      t.timestamps
    end

    end

  def self.down
    drop_table :mockdata
    drop_table :missed_requests
  end
end