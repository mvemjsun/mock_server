# encoding: utf-8
class Mockdata < ActiveRecord::Base

  validates :mock_name,   presence: true
  validates :mock_http_status,   presence: true, numericality: true, length: { is: 3 }
  validates :mock_request_url,   presence: true
  validates :mock_data_response_headers,   presence: true
  validates :mock_data_response,   presence: true
  # validates :mock_state ,   presence: true
  validates :mock_content_type,   presence: true
  validates :mock_environment, presence: true

  before_save do
    self.mock_name = self.mock_name.upcase
    self.mock_served_times = 0 if self.mock_served_times.nil?
  end

 end