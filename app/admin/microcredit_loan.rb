ActiveAdmin.register MicrocreditLoan do
  menu :parent => "Microcredits"

  index do
    selectable_column
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
      row :user_data do
        attributes_table_for YAML.load(microcredit_loan.user_data) do
            row :first_name
            row :last_name
            row :address
            row :postal_code
            row :town
            row :province
            row :country
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
  
  filter :microcredit
  filter :created_at
  filter :counted_at, if: proc{ can? :admin, MicrocreditLoan }
end
