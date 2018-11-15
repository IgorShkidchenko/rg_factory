class Factory
  class << self
  def new *arg_from_fact, &method
    new_class = Class.new do
      define_method :initialize do |*arg_from_new_class|
        raise ArgumentError, 'Extra args passed' unless arg_from_fact.count == arg_from_new_class.count
        zipped = arg_from_fact.zip(arg_from_new_class)
        zipped.each { |variable, value| instance_variable_set("@#{variable}", value) }
        arg_from_fact.each { |variable| self.class.send(:attr_accessor, variable) }
      end

      def []= variable, value
        if variable.is_a? Integer
          raise IndexError, "Index #{variable} doesn't exist" if instance_variables.count - 1 < variable
          return instance_variable_set(instance_variables[variable], value)
        end
        raise NameError, "Name #{variable} doesn't exist" unless instance_variables.to_s.include? ":@#{variable}"
        instance_variable_set("@#{variable}", value)
      end

      def [] variable
        if variable.is_a? Integer
          raise IndexError, "Index #{variable} doesn't exist" if instance_variables.count - 1 < variable
          return instance_variable_get(instance_variables[variable])
        end
        raise NameError, "Name #{variable} doesn't exist" unless instance_variables.to_s.include? ":@#{variable}"
        instance_variable_get("@#{variable}")
      end

      def == other
        i = 0
        variables_value = -> (i, who = self) { who.instance_variable_get(instance_variables[i]) }
        instance_variables.size.times do 
          return false unless variables_value.call(i) == variables_value.call(i, other)
          i += 1
        end
        true
      end

      def each &method
        to_a.each &method
      end

      def select &method
        to_a.select &method
      end

      def values_at *index
        to_a.values_at *index
      end

      def to_a
        to_h.values
      end

      def to_h
        pair = instance_variables.map do |variable|
          [variable.slice(1, variable.size).to_sym, instance_variable_get(variable)]
        end
        pair.to_h
      end

      def size
        instance_variables.count
      end

      def members
        to_h.keys
      end

      def each_pair &method
        to_h.each_pair &method
      end

      def dig *path
        to_h.dig *path
      end
      
      class_eval &method if block_given?
      alias_method :length, :size
      alias_method :eql?, :==
    end
    const_set(arg_from_fact.shift.capitalize, new_class) if arg_from_fact.first.is_a? String
    new_class
  end
end
end
