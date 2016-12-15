# encoding: utf-8
class Replacedata < ActiveRecord::Base

  validates :replace_name, presence: true
  validates :replaced_string, presence: true
  validates :replacing_string, presence: true
  validates :mock_environment, presence: true
  # validates :replace_state, presence: true
  # validates :is_regexp, presence: true

  before_save do
    self.replace_name = self.replace_name.upcase
  end


  #
  # Activate the replace data row of interest. Replace data does not have any unique constraints. If we activate a
  # replace data row any other row with the same replace string will be deactivated
  # @param [Fixnum] id Id of the replace data row
  # @return [Boolean] true or false
  #
  def activate_replace_mock_data(id)
    found = true
    Replacedata.transaction do
      replace_data = Replacedata.where(id: id)
      if replace_data.any?
        string_to_be_replaced = replace_data.first.replaced_string
        st1 = ActiveRecord::Base.connection.raw_connection.prepare("UPDATE REPLACEDATA SET replace_state = ? WHERE replaced_string = ?")
        st1.execute('f', string_to_be_replaced)
        st2 = ActiveRecord::Base.connection.raw_connection.prepare("UPDATE REPLACEDATA SET replace_state = ? WHERE id = ?")
        st2.execute('t', id)
      else
        found = false
      end
    end
    return found
  end

  #
  # Set a Replace data mock status to OFF
  # @param [Fixnum] if of the replace mock data
  # @return [Boolean] True of False depending on if the mock id was found and updated
  #
  def deactivate_replace_mock_data(id)
    found = true
    Replacedata.transaction do
      replace_data = Replacedata.where(id: id)
      if replace_data.any?
        st2 = ActiveRecord::Base.connection.raw_connection.prepare("UPDATE REPLACEDATA SET replace_state = ? WHERE id = ?")
        st2.execute('f', id)
      else
        found = false
      end
    end
    return found
  end

  #
  # Update the column replacing_string with the string supplied
  # @param [String] matching - String to be matched
  # @param [String] with - Replacement String
  # @example update_replace_string("127.0.0.1","196.2.34.67") will scan through all rows and replace any occurance of
  #         the matching string "127.0.0.1" with "196.2.34.67"
  #
  def self.update_replace_string(matching,with)
    Replacedata.find_each do |replace_data|
      replace_data.replacing_string = replace_data.replacing_string.gsub(matching,with)
      replace_data.save!
    end
  end
end