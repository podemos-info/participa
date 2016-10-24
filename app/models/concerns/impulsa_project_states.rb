module ImpulsaProjectStates
  extend ActiveSupport::Concern

  included do

    before_create do
      self.create_project
    end
    
    state_machine initial: :unsaved do
      event :create_project do
        transition :unsaved => :new
      end

      event :mark_for_review do
        transition :new => :review, unless: :wizard_has_errors?
        transition :fixes => :review_fixes, unless: :wizard_has_errors?
      end

      event :mark_as_spam do
        transition all => :spam
      end

      state :unsaved, :new, :review, :spam do
        def editable?
          self.impulsa_edition.allow_edition?
        end

        def reviewable?
          false
        end
      end

      state :fixes, :review_fixes do
        def editable?
          false
        end
        
        def reviewable?
          self.impulsa_edition.allow_fixes?
        end
      end

      state all - [:new, :review, :fixes, :review_fixes, :spam] do
        def editable?
          false
        end

        def reviewable?
          false
        end
      end
    end

    def saveable?
      editable? || reviewable?
    end

    def deleteable?
      editable?
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