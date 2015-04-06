ActiveAdmin.register Microcredit do
  permit_params :title, :starts_at, :ends_at, :limits, :account_number

  index do
    selectable_column
    id_column
    column :title
    column :starts_at
    column :ends_at
    column :current do |m|
      "#{m.current_confirmed} / #{m.current_lent} / #{m.current_limit}"
    end
    column :total do |m|
      "#{m.total_confirmed} / #{m.total_lent}"
    end
  end

  form do |f|
    f.inputs "Colaboración" do
      f.input :title
      f.input :starts_at
      f.input :ends_at
      f.input :account_number
      f.input :limits
    end
    f.actions
  end

  action_item :only => :show do
    link_to('Reiniciar', reset_admin_microcredit_path(resource), method: :post, data: { confirm: "¿Estas segura de que deseas reiniciar esta campaña?" })
  end

  member_action :reset, :method => :post do
    Microcredit.find(params[:id]).reset
    flash[:notice] = "La campaña ha sido reiniciada."
    redirect_to action: :show
  end

end
