module Boil
  module Composer
    module ReflectionHelpers
      ClassConstNotFound = Class.new(RuntimeError)
    
      def constructor_parameters(cls)
        parameters = cls.instance_method(:initialize).parameters
        return [] if parameters == [[:rest]]
        parameters.map {|req, name| name || req }
      end

      def class_name?(name)
        begin
          name.constantize.is_a?(Class)
        rescue NameError
          false
        end
      end
    
      def constantize_class(class_or_name)
        puts "constantize_class (#{class_or_name.inspect})"
        begin
          class_or_name.is_a?(String) ? class_or_name.constantize : class_or_name
        rescue NameError
          raise ClassConstNotFound
        end
      end
    end
  end
end