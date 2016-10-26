module ImpulsaProjectStates
  extend ActiveSupport::Concern

  included do
    
    state_machine initial: :new do
      audit_trail

      event :mark_for_review do
        transition :new => :review, if: :markable_for_review?
        transition :spam => :review, if: :markable_for_review?
        transition :fixes => :review_fixes, if: :markable_for_review?
      end

      event :mark_as_spam do
        transition all => :spam
      end

      event :mark_as_fixes do
        transition :review => :fixes
        transition :review_fixes => :fixes
      end
      event :mark_as_dissent do
        transition :validate => :dissent
      end
      event :mark_as_validated do
        transition :validate => :validated
      end
      event :mark_as_invalidated do
        transition :validate => :invalidated
      end

      state :new, :review, :spam do
        def editable?
          !self.persisted? || self.impulsa_edition.allow_edition?
        end
      end

      state all - [:new, :review, :spam] do
        def editable?
          false
        end
      end
    end

    def reviewable?
      review?
    end

    def markable_for_review?
      !reviewable? && saveable? && !wizard_has_errors?
    end

    def saveable?
      editable? || fixable?
    end

    def deleteable?
      editable?
    end

    def fixable?
      fixes? && self.impulsa_edition.allow_fixes?
    end


    def validable?
      validate?
    end
  end
end

'''

  def editable?
    !persisted? || (self.impulsa_edition.allow_edition? && (self.status < PROJECT_STATUS[:fixes] || self.spam?))
  end

  def reviewable?
    self.impulsa_edition.allow_fixes? && (marked_for_review? || new? || fixes?)
  end

  PROJECT_STATUS = {
    new: 0,
    review: 1,
    fixes: 2,
    review_fixes: 3,
    validate: 4,
    invalidated: 5,
    validated: 6,
    discarded: 7,
    resigned: 8,
    winner: 9,
    spam: 10,
    dissent: 11
  }
  def new?
    self.status==PROJECT_STATUS[:new]
  end

  def review?
    self.status==PROJECT_STATUS[:review]
  end

  def fixes?
    self.status==PROJECT_STATUS[:fixes]
  end

  def spam?
    self.status==PROJECT_STATUS[:spam]
  end

  def allow_save_draft?
    self.new? || self.spam? || self.fixes? || (self.marked_for_review? && self.errors.any?)
  end

  def marked_for_review?
    self.status==PROJECT_STATUS[:review] || self.status==PROJECT_STATUS[:review_fixes]
  end

  def marked_as_validable?
    self.status==PROJECT_STATUS[:validate]
  end

  def should_be_valid?
    self.marked_for_review? || self.marked_as_validable?
  end

  def mark_as_new
    self.status=PROJECT_STATUS[:new] if self.review? || self.spam?
  end

  def mark_as_spam
    self.status=PROJECT_STATUS[:spam] if self.new?
  end

  def mark_for_review
    if self.new? || self.spam?
      self.status=PROJECT_STATUS[:review]
    elsif self.fixes?
      self.status=PROJECT_STATUS[:review_fixes]
    end
  end

  def mark_as_fixable
    self.status=PROJECT_STATUS[:fixes]
  end

  def mark_as_validable
    self.status=PROJECT_STATUS[:validate]
  end   

  def mark_as_winner
    self.status=PROJECT_STATUS[:winner]
  end 

  def validable?
    self.status==PROJECT_STATUS[:validate] && self.impulsa_edition.allow_validation?
  end

  def invalidated?
    self.status==PROJECT_STATUS[:invalidated]
  end

  def validated?
    self.status==PROJECT_STATUS[:validated]
  end

  def discarded?
    self.status==PROJECT_STATUS[:discarded]
  end

  def winner?
    self.status==PROJECT_STATUS[:winner]
  end

  def dissent?
    self.status==PROJECT_STATUS[:dissent]
  end

  def status_name
    ImpulsaProject::STATUS_NAMES.invert[self.status]
  end
'''