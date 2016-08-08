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
        st1.execute('0', string_to_be_replaced)
        st2 = ActiveRecord::Base.connection.raw_connection.prepare("UPDATE REPLACEDATA SET replace_state = ? WHERE id = ?")
        st2.execute('1',id)
      else
        found = false
      end
    end
    return found
  end
end