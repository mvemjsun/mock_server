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

    add_index :mockdata, [:mock_name,:mock_request_url, :mock_environment, :mock_state], :unique => true, name: 'unique_data'
  end

  def self.down
    drop_table :mockdata
  end
end