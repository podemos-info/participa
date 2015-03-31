# http://codeconnoisseur.org/ramblings/creating-dynamic-routes-at-runtime-in-rails-4
class Page < ActiveRecord::Base

  validates :id_form, uniqueness: { case_sensitive: false, scope: :deleted_at }, presence: true, :numericality => { :greater_than_or_equal_to => 0 }
  validates :slug, uniqueness: { case_sensitive: false, scope: :deleted_at }, presence: true
  validates :title, presence: true

  acts_as_paranoid

  after_save :reload_routes

  def reload_routes
    DynamicRouter.reload
  end
end
