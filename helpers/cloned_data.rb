class ClonedData
  def method_missing(m, *args, &block)
    attr = m.to_s.sub('=','')
    attr_value = *args.last
    self.instance_variable_set("@#{attr}", (attr_value.nil? || attr_value.length) == 0 ? nil : attr_value.first)
    self.class.define_attr_accessor(attr)  # Call a custom method to define the accessor
  end

  def self.define_attr_accessor(attr)
    attr_accessor attr
  end
end