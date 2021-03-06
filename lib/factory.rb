class Factory
  class << self
    def new *arg_from_fact, &method
      const_set(arg_from_fact.shift.capitalize, new_class(*arg_from_fact, &method)) if arg_from_fact.first.is_a? String
      new_class *arg_from_fact, &method
    end

    def new_class *arg_from_fact, &method
      Class.new do
        attr_accessor *arg_from_fact

        define_method :initialize do |*arg_from_new_class|
          raise ArgumentError, 'Extra args passed' if !(arg_from_fact.count == arg_from_new_class.count)
          arg_from_fact.zip(arg_from_new_class).each { |variable, value| instance_variable_set("@#{variable}", value) }
        end

        def []= variable, value
          return instance_variable_set(instance_variables[variable]), value if variable.is_a? Integer
          instance_variable_set("@#{variable}", value)
        end

        def [] variable
          return instance_variable_get(instance_variables[variable]) if variable.is_a? Integer
          instance_variable_get("@#{variable}")
        end

        def == other
          self.class == other.class && self.to_a == other.to_a
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
          instance_variables.map { |values| instance_variable_get values }
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
          path.inject(to_h) { |key, value| key[value] if key[value] }
        end

        define_method :to_h do
          arg_from_fact.zip(to_a).to_h
        end
        
        class_eval &method if block_given?
        alias_method :length, :size
        alias_method :eql?, :==
      end
    end
  end
end
