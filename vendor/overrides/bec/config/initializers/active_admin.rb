ActiveAdmin.setup do |config|

  config.namespace :admin do |admin|
    admin.build_menu :utility_navigation do |menu|
      menu.add :label => "Idiomas" do |lang|
        lang.add :label => "catalá",:url => proc { url_for(:locale => 'ca') }, id: 'i18n-ca', :priority => 1
        lang.add :label => "castellano",:url => proc { url_for(:locale => 'es') }, id: 'i18n-es', :priority => 2
      end
      menu.add :label => proc { display_name current_active_admin_user },
                :url => '#',
                :id => 'current_user',
                :if => proc { current_active_admin_user? }
      admin.add_logout_button_to_menu menu
    end
  end

end
