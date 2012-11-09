require_relative '../../../lib/boil/composer/builder'


describe Boil::Composer::Builder do

  
  describe "given classes in the same namespace" do

    module CommonModule
      class Independent
        def initialize
        end
      end

      class Dependent
        def initialize(independent)
          @independent = independent
        end

        attr_reader :independent
      end

      class VeryDependent
        def initialize(independent, dependent)
          @independent = independent
          @dependent = dependent
        end

        attr_reader :independent
        attr_reader :dependent
      end

      class DependentOnPredefined
        def initialize(predefined)
          @predefined = predefined
        end

        attr_reader :predefined
      end

      class DependentOnNonExisting
        def initialize(non_existing)
        end
      end

      class Circular1
        def initialize(circular2)
        end
      end

      class Circular2
        def initialize(circular1)
        end
      end

      class DependentOnConflicting
        def initialize(conflicting)
        end
      end

      class Conflicting
      end
    end

    
    let(:target_class) do
      Class.new do
        extend Boil::Composer::Builder
  
        def predefined
          "predefined"
        end
  
        def conflicting
        end
      end
    end
    
    before do
      ::Module.module_eval do
        include CommonModule
      end
    end
    
    it "should create factory method for class with parameter-less constructor" do
      target_class.create_factory_method_for(CommonModule::Independent)
      target_class.new.should respond_to(:independent)
    end

    it "should create only one instance with multiple calls to factory method" do
      target_class.create_factory_method_for(CommonModule::Independent)
      target = target_class.new
      target.independent.should_not be_nil
      target.independent.should == target.independent
    end

    it "should create factory method depending on another class" do
      target_class.create_factory_method_for(CommonModule::Dependent)
      target = target_class.new
      target.should respond_to(:independent)
      target.should respond_to(:dependent)
      target.independent.should == target.dependent.independent
    end

    it "should support multiple root classes" do
      target_class.create_factory_method_for(CommonModule::Dependent, CommonModule::VeryDependent)
      target = target_class.new
      target.should respond_to(:independent)
      target.should respond_to(:dependent)
      target.should respond_to(:very_dependent)
      target.very_dependent.dependent == target.dependent
      target.very_dependent.dependent.independent == target.dependent.independent
    end

    it "should support pre-defined factory method" do
      target_class.create_factory_method_for(CommonModule::DependentOnPredefined)
      target = target_class.new
      target.should respond_to(:dependent_on_predefined)
      target.dependent_on_predefined.predefined.should == target.predefined
    end

    it "should raise error if no factory method and no matching class" do
      lambda { target_class.create_factory_method_for(CommonModule::DependentOnNonExisting) }.should raise_error
    end

    it "should raise error for circular dependencies" do
      lambda { target_class.create_factory_method_for(CommonModule::Circular1) }.should raise_error
      lambda { target_class.create_factory_method_for(CommonModule::Circular1) }.should_not raise_error(SystemStackError)
    end

    it "should raise error if methods conflict" do
      lambda { target_class.create_factory_method_for(CommonModule::DependentOnConflicting) }.should raise_error
    end

    it "should list factory methods" do
      target_class.create_factory_method_for(CommonModule::Dependent, CommonModule::VeryDependent)
      target_class.factory_methods.should have(3).items
    end
  end
  
  describe "given classes in different namespaces" do
  end
end
