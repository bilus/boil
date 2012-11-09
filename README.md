Automatic construction of interdependent objects using Ruby reflection and meta-programming.

---

TODO
----

- Interdependent classes in different modules.

---

Quick start
-----------

	> gem install boil
	
	An example: 
	
	ReviewSubmissionPresenter
      ReviewSubmissionView
      ReviewSubmissionModel
        ReviewStore
        ReviewValidationPolicy
        ReviewResubmissionPolicy
        
  (TODO: insert image of dependency diagram)

  With classes in the global namespace or in the same module, it uses reasonable defaults.
  
  Here are the interdependent classes. 

      class ReviewSubmissionPresenter
        def initialize(review_submission_view, review_submission_model)
        # ...
        end
      end

      class ReviewSubmissionModel
        def initialize(review_workflow_policy)
        # ...
        end
      end

      def ReviewSubmissionView
        # ...
      end

      class ReviewWorkflowPolicy
        def initialize(review_store, review_validation_policy, review_resubmission_policy)
        # ...
        end
      end
      
  Notice that constructor argument names correspond to class names.
  
  To create a factory method for any of the classes:
  
      require 'boil'
  
      include Boil::Composer::Builder

      # Creates factory method in the current scope.
      create_factory_method_for(ReviewSubmissionPresenter) 
      
      # Create an instance:
      presenter = review_submission_presenter
      
      # It automatically creates factory methods for all classes ReviewSubmissionPresenter depends on:
      policy = review_workflow_policy
      
  DISCLAIMER: Obviously, you would not pollute the global scope with factory methods like that, it's just an example. Use it from within a class or module.
  
  **TODO** With classes in different namespaces, you need to explicitly compose:
  
      module Presenters
        class ReviewSubmissionPresenter
          include Boil::Composer
          compose view: Views::ReviewSubmissionView
          compose model: Models::ReviewSubmissionModel

          def initialize(view, model)
          # ...
          end
        end

      module Models
      
        class ReviewSubmissionModel
          include Boil::Composer
          compose review_workflow_policy: Policies::ReviewWorkflowPolicy
        
          def initialize(review_workflow_policy)
          # ...
          end
        end
      end
      
      module Views
        def ReviewSubmissionView
          # ...
        end
      end
      
      
      module Policies
        class ReviewWorkflowPolicy
          include Boil::Composer
          
          compose 
            review_store: Stores::ReviewStore,
            review_validation_policy: Policies::ReviewValidationPolicy,
            review_resubmission_policy: Policies::ReviewResubmissionPolicy

        
          def initialize(review_store, review_validation_policy, review_resubmission_policy)
          # ...
          end
        end
      
        class ReviewValidationPolicy
        end
      
        class ReviewResubmissionPolicy
          include Boil::Composer
          compose review_store: DataStores::ReviewStore
          
          def initialize(review_store)
          end
        end
      end
      
      module DataStores
        class ReviewStore
        end
      end
