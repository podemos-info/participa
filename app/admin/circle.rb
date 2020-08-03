ActiveAdmin.register Circle do
  menu :parent => "Users"
  #permit_params :original_code, :original_name

  index download_links: -> { current_user.is_admin? && current_user.superadmin? }

end
