ActiveAdmin.register Category do
  menu :parent => "Blog"
  permit_params :name, :slug

end
