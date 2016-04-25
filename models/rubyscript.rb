# encoding: utf-8
class Rubyscript < ActiveRecord::Base
  validates :script_name, uniqueness: true,  presence: true, format: { with: /\A[a-zA-Z]\S+\z/,message: '.Please enter valid script name without spaces.' }

end