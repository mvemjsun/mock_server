# encoding: utf-8
class Mockdata < ActiveRecord::Base

  validates :mock_name, presence: true
  validates :mock_http_status, presence: true, format: {with: /\A[12345]\d{2}\z/, message: '.Please enter a valid HTTP code.'}
  validates :mock_request_url, presence: true
  validates :mock_http_verb, presence: true
  validates :mock_data_response_headers, presence: true
  validate :validate_headers
  validate :mock_data_response_body
  validates :mock_content_type, presence: true
  validates :mock_environment, presence: true
  validate :validate_script_state
  validate :validate_script_name


  before_save do
    self.mock_name = self.mock_name.gsub(/\s+/, ' ').strip.upcase
    self.mock_http_verb = self.mock_http_verb.upcase
    self.mock_served_times = 0 if self.mock_served_times.nil?
    self.after_script_name = self.after_script_name.nil? ? nil : after_script_name
    self.before_script_name = self.before_script_name.nil? ? nil : before_script_name
    self.profile_name = self.profile_name.nil? ? '' : self.profile_name.gsub(/\s+/, ' ').strip.upcase
  end

  def mock_data_response_body
    if self.mock_http_status.match(/^[^4-5]/) && self.mock_data_response.size == 0
      errors.add(:mock_data_response, "can't be blank.")
    end
  end

  def validate_headers
    supplied_headers = self.mock_data_response_headers.split(/\r\n/)
    supplied_headers.each do |header_data|
      errors.add(mock_data_response_headers, " ** Header #{header_data} is not delimited correctly **") unless header_data.match(ENV['HEADER_DELIMITER'])
    end
  end

  def validate_script_name
    if (!self.before_script_name.nil? && self.before_script_name.length > 0)
      scripts = self.before_script_name.split(/,/)
      scripts.each do |script_name|
        if !script_name.match(/^\s*\w+\.rb\s*$/)
          errors.add(:before_script_name, "- Script name #{script_name} is invalid. ")
        end
      end
    end

    if (!self.after_script_name.nil? && self.after_script_name.length > 0)
      scripts = self.after_script_name.split(/,/)
      scripts.each do |script_name|
        if !script_name.match(/^\s*\w+\.rb\s*$/)
          errors.add(:after_script_name, "- Script name #{script_name} is invalid. ")
        end
      end
    end
  end

  def validate_script_state
    if self.has_before_script == true
      if (self.before_script_name.nil? || self.before_script_name.length == 0)
        errors.add(:before_script_name, '- Provide a before script name ending with .rb')
      end
    end

    if self.has_after_script == true
      if (self.after_script_name.nil? || self.after_script_name.length == 0)
        errors.add(:after_script_name, '- Provide a after script name ending with .rb')
      end
    end
  end

  def activate_mock_data(id)
    found = true
    env = ENV['TEST_ENV']
    Replacedata.transaction do
      mock_data = Mockdata.where(id: id)
      if mock_data.any?
        mock_url = mock_data.first.mock_request_url
        st1 = ActiveRecord::Base.connection.raw_connection.prepare('UPDATE MOCKDATA SET mock_state = ? WHERE mock_request_url = ? and mock_environment = ?')
        st1.execute('f', mock_url,env)
        st2 = ActiveRecord::Base.connection.raw_connection.prepare('UPDATE MOCKDATA SET mock_state = ? WHERE id = ?')
        st2.execute('t',id)
        # Refresh wildcard cache
        $wild_routes = WildRoutes.get_wild_routes_if_any if mock_url.index('*')
        p $wild_routes
      else
        found = false
      end
    end
    return found
  end

end