class ClonedData

  def method_missing(m, *args, &block)
    attr = m.to_s.sub('=','')
    attr_value = *args.last
    self.instance_variable_set("@#{attr}", attr_value.length == 0 ? nil : attr_value.first)
    self.class_eval { attr_accessor "#{attr}" }
  end
end