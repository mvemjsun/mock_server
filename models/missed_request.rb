# encoding: utf-8
class MissedRequest < ActiveRecord::Base

  validates :url,   presence: true
  validates :mock_environment, presence: true

  before_save do
    self.mock_environment = ENV['TEST_ENV']
  end

end