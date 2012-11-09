Automatic building of composed objects using Ruby reflection and meta-programming.

---

TODO
----

- Global namespace.
- Same module.
- Different modules.

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

  With classes in the global namespace or in the same module, it uses reasonable defaults:

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

  
  **TBD** With different module, you need to explicitly compose:
  
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
