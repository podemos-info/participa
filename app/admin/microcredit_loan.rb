ActiveAdmin.register MicrocreditLoan do
  menu :parent => "Microcredits"

  index download_links: proc{ can?(:admin, MicrocreditLoan) } do
    selectable_column if can? :admin, MicrocreditLoan
    id_column
    column :microcredit do |loan|
      if can? :show, loan.microcredit
        link_to(loan.microcredit.title, admin_microcredit_path(loan.microcredit))
      else
        loan.microcredit.title
      end
    end
    column :user do |loan|
      if loan.user and can? :show, loan.user
        link_to(loan.user.full_name, admin_user_path(loan.user))
      else
        "#{loan.first_name} #{loan.last_name}"
      end
    end
    column :document_vatid
    column :amount do |loan|
      number_to_euro loan.amount*100
    end
    column :created_at
    column :confirmed_at
    column :counted_at if can? :admin, MicrocreditLoan
  end

  show do
    attributes_table do
      row :id
      row :microcredit do
        if can? :show, microcredit_loan.microcredit
          link_to(microcredit_loan.microcredit.title, admin_microcredit_path(microcredit_loan.microcredit))
        else
          microcredit_loan.microcredit.title
        end
      end
      row :user do
        if microcredit_loan.user and can? :show, microcredit_loan.user
          link_to(microcredit_loan.user.full_name, admin_user_path(microcredit_loan.user))
        else
          "#{microcredit_loan.first_name} #{microcredit_loan.last_name}"
        end
      end
      row :amount do
        number_to_euro microcredit_loan.amount*100
      end
      row :document_vatid
      row :ip if can? :admin, MicrocreditLoan
      row :user_data do
        attributes_table_for microcredit_loan do
            row :first_name
            row :last_name
            row :address
            row :postal_code
            row :country_name
            row :province_name
            row :town_name
          end
      end if microcredit_loan.user.nil? and can? :admin, MicrocreditLoan
      row :created_at
      row :confirmed_at
      row :counted_at if can? :admin, MicrocreditLoan
    end
    active_admin_comments
  end

  scope :all
  scope :confirmed
  scope :counted, if: proc{ can? :admin, MicrocreditLoan }
  
  filter :id
  filter :microcredit
  filter :document_vatid
  filter :created_at
  filter :counted_at, if: proc{ can? :admin, MicrocreditLoan }

  action_item :only => :show do
    if microcredit_loan.confirmed_at.nil?
      link_to('Confirmar', confirm_admin_microcredit_loan_path(microcredit_loan), method: :post, data: { confirm: "¿Estas segura de querer confirmar la recepción de este microcrédito?" })
    else
      link_to('Des-confirmar', confirm_admin_microcredit_loan_path(microcredit_loan), method: :delete, data: { confirm: "¿Estas segura de querer cancelar la confirmación de la recepción de este microcrédito?" })
    end
  end

  member_action :confirm, :method => [:post, :delete] do
    m = MicrocreditLoan.find(params[:id])
    if request.post?
      m.confirmed_at = DateTime.now
    else
      m.confirmed_at = nil
    end
    m.save
    flash[:notice] = "La recepción del microcrédito ha sido confirmada."
    redirect_to action: :show
  end
end
