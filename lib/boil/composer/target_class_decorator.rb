module Boil
  module Composer
    class TargetClassDecorator
      include ReflectionHelpers
    
      def initialize(target_class)
        @target_class = target_class
      end
    
      def define_factory_method(class_or_name)
        factory_method_name = factory_method_name(class_or_name)
        prevent_old_method_override(factory_method_name)
        unless @target_class.method_defined?(factory_method_name)
          cls = constantize_class(class_or_name)
          constructor_params = constructor_parameters(cls)
          @target_class.send(:define_method, factory_method_name) do
            instance_variable_name = "@#{factory_method_name.to_s}".to_sym
            instance_variable = instance_variable_get(instance_variable_name)
            if instance_variable
              instance_variable
            else
              instance_variable_set(instance_variable_name, cls.new(*constructor_params.map {|p| send(p)}))
            end
          end 
          register_factory_method(factory_method_name)
        end
      end
    
      def method_defined?(meth)
        @target_class.method_defined?(meth)
      end

      def factory_method?(meth)
        factory_methods.include?(meth)
      end
    
      def factory_methods
        if @target_class.class_variable_defined?(FACTORY_METHODS_VAR_NAME) 
          @target_class.class_variable_get(FACTORY_METHODS_VAR_NAME)
        else
          []
        end
      end
    
      private
    
      def prevent_old_method_override(meth)
        raise "Factory method #{meth} conflicts with an existing method." if method_defined?(meth) && !factory_method?(meth)
      end
        
      FACTORY_METHODS_VAR_NAME = "@@__factory_methods"
    
      def register_factory_method(meth)
        @target_class.class_variable_set(FACTORY_METHODS_VAR_NAME, []) unless @target_class.class_variable_defined?(FACTORY_METHODS_VAR_NAME)
        factory_methods = @target_class.class_variable_get(FACTORY_METHODS_VAR_NAME)
        factory_methods << meth
      end
      
      def factory_method_name(class_or_name)
        # Looks odd but it's there to use only the class name if it's in a module.
        # "Boil::Composer::Independent".underscore => "boil/composer/independent" 
        # File.basename takes the last component.
        # This will create clashes for classes with identical names (in different modules).
        File.basename("#{class_or_name.to_s.underscore}").to_sym
      end
    end
  end
end