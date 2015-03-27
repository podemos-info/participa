# http://codeconnoisseur.org/ramblings/creating-dynamic-routes-at-runtime-in-rails-4
class DynamicRouter

  def self.load
    if ActiveRecord::Base.connection.table_exists? 'pages'
      Rails.application.routes.draw do
        scope "/(:locale)", locale: /es|ca|eu/ do 
          Page.all.each do |pag|
            get "#{pag.slug}", :to => "page#show_form", defaults: { id: pag.id }
          end
        end
      end
    end
  end

  def self.reload
    Rails.application.routes_reloader.reload!
  end
end
