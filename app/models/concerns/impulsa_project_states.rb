module ImpulsaProjectStates
  extend ActiveSupport::Concern

  included do
    scope :exportable, -> { state: [ :validated, :winner ] }

    state_machine initial: :new do
      audit_trail

      event :mark_as_spam do
        transition all => :spam
      end
      
      event :mark_for_review do
        transition :new => :review, if: :markable_for_review?
        transition :spam => :review, if: :markable_for_review?
        transition :fixes => :review_fixes, if: :markable_for_review?
      end

      event :mark_as_fixes do
        transition :review => :fixes
        transition :review_fixes => :fixes
      end
      event :mark_as_validable do
        transition :review => :validable
        transition :review_fixes => :validable
      end
      event :mark_as_validated do
        transition :validable => :validated, if: :evaluation_result?
      end
      event :mark_as_invalidated do
        transition :validable => :invalidated, if: :evaluation_result?
      end
      event :mark_as_winner do
        transition :validated => :winner
      end
      event :mark_as_resigned do
        transition all => :resigned
      end

      state :new, :review, :spam do
        def editable?
          !self.persisted? || (!resigned? && self.impulsa_edition.allow_edition?)
        end
      end

      state all - [:new, :review, :spam] do
        def editable?
          false
        end
      end
    end

    def saveable?
      !resigned? && (editable? || fixable?)
    end

    def reviewable?
      persisted? && !resigned? && (review? || review_fixes?)
    end

    def markable_for_review?
      persisted? && !resigned? && !reviewable? && saveable? && !wizard_has_errors?
    end

    def deleteable?
      persisted? && !resigned? && editable?
    end

    def fixable?
      persisted? && !resigned? && fixes? && self.impulsa_edition.allow_fixes?
    end
  end

end