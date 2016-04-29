# encoding: utf-8
class Rubyscript < ActiveRecord::Base
  validates :script_name, uniqueness: true,  presence: true, format: { with: /\A[a-zA-Z]\S+.rb\z/,message: '.Please enter valid script name without spaces ending with .rb.' }

end