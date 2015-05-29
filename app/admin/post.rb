ActiveAdmin.register Post do
  menu :parent => "Blog"

  scope_to Post, association_method: :with_deleted

  scope :created, default: true
  scope :published
  scope :deleted

  index do
    selectable_column
    id_column
    column :title
    column :categories do |post|
      (post.categories.map {|c| link_to(c.name, admin_category_path(c)).html_safe } .join ", ").html_safe
    end
    column :created_at
    column :status do |post|
      status_tag("Publicado", :ok) if post.published?
      status_tag("Borrado", :error) if post.deleted?
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row :status do
        status_tag("Publicado", :ok) if post.published?
        status_tag("Borrado", :error) if post.deleted?
      end
      row :title
      row :content do
        simple_format post.content
      end

      row :slug
      row :categories do
        (post.categories.map {|c| link_to(c.name, admin_category_path(c)).html_safe } .join ", ").html_safe
      end
      row :created_at
      row :updated_at
      row :deleted_at if post.deleted?
    end
  end

  form do |f|
    f.inputs "Posts" do
      f.input :status, as: :select, collection: Post::STATUS.to_a
      f.input :title
      f.input :content    
      f.input :media_url
      f.input :categories, as: :check_boxes, collection: Category.all
    end
    f.actions
  end

  permit_params :title, :content, :media_url, :slug, :status, category_ids: []
end
