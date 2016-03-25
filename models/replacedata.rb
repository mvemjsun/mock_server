# encoding: utf-8
class Replacedata < ActiveRecord::Base

  validates :replace_name,   presence: true
  validates :replaced_string,   presence: true
  validates :replacing_string,   presence: true
  validates :mock_environment, presence: true
  # validates :replace_state, presence: true
  # validates :is_regexp, presence: true

  before_save do
    self.replace_name = self.replace_name.upcase
  end


end