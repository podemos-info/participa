ActiveAdmin.register MicrocreditLoan do
  menu :parent => "Microcredits"

 index do
    selectable_column
    id_column
    column :microcredit
    column :user
    column :amount do |g|
      number_to_euro g.amount*100
    end
    column :created_at
    column :confirmed_at
  end

end
