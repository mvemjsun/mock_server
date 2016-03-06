# encoding: utf-8
class Mockdata < ActiveRecord::Base

  # attr_accessor :mock_name,:mock_http_status, :mock_request_url,:mock_data_response_headers, :mock_data_response, :mock_state, :mock_environment

  validates :mock_name,   presence: true
  validates :mock_http_status,   presence: true, numericality: true, length: { is: 3 }
  validates :mock_request_url,   presence: true
  validates :mock_data_response_headers,   presence: true
  validates :mock_data_response,   presence: true
  validates :mock_state,   presence: true
  validates :mock_content_type,   presence: true
  validates :mock_environment, presence: true #,  inclusion: { in: %w(production, integration, quality)}

  before_save do
    self.mock_request_url = self.mock_request_url.sub!(/^\//, '')
  end

  before_update do
    self.mock_request_url = self.mock_request_url.sub!(/^\//, '')
  end
 end