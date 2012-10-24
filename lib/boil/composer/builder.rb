require 'active_support/inflector' # String.camelize, String.constantize, String.underscore
require_relative './reflection_helpers'
require_relative './dependency_walker'
require_relative './target_class_decorator'

module Boil
  module Composer
    module Builder
      def create_factory_method_for(*classes)
        classes.each do |cls|
          DependencyWalker.new(TargetClassDecorator.new(self)).create_factory_method_for_class(cls)
        end
      end
    
      def factory_methods
        TargetClassDecorator.new(self).factory_methods
      end
    end
  end
end