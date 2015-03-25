# http://codeconnoisseur.org/ramblings/creating-dynamic-routes-at-runtime-in-rails-4
class DynamicRouter

  def self.load
    Rails.application.routes.draw do
      Page.all.each do |pag|
        get "#{pag.slug}", :to => "page#show_form", defaults: { id: pag.id }
      end
    end
  end

  def self.reload
    Rails.application.routes_reloader.reload!
  end

end
