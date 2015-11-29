class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # ...
    names.each do |variable_name|
      define_method(variable_name) do
        instance_variable_get("@#{variable_name}")
      end
      variable_set = "#{variable_name}=".to_sym
      define_method(variable_set) do |value|
        instance_variable_set("@#{variable_name}", value)
      end
    end
  end
end
