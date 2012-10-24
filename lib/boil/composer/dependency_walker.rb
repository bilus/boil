module Boil
  module Composer
    class DependencyWalker
      include ReflectionHelpers
    
      def initialize(target_class)
        @target_class = target_class
      end
    
      def create_factory_method_for_class(cls)
        begin
          create_factory_methods_for_dependencies(constantize_class(cls))
          @target_class.define_factory_method(cls)
        rescue SystemStackError
          raise "Stack too deep when trying to define factory method for #{cls} -- circular reference in initialize parameters?"
        end
      end

      def create_factory_methods_for_dependencies(cls)
        constructor_parameters(cls).each do |param|
          begin
            if class_name?(class_from_constructor_param(cls, param))
              create_factory_method_for_class(class_from_constructor_param(cls, param))
            else 
              # If it's already defined, we don't care that there is no corresponding class.
              raise ClassConstNotFound unless @target_class.method_defined?(param)
            end
          rescue ClassConstNotFound
            class_name = class_from_constructor_param(cls, param)
            raise "#{cls} has constructor argument '#{param}' without a corresponding class (#{class_name})"
          end
        end
      end

      def class_from_constructor_param(parent_class, constructor_param)
        constructor_param.to_s.camelize
      end
    end
  end
end