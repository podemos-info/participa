ActiveAdmin.register MicrocreditLoan do

  permit_params :user_id, :microcredit_id, :document_vatid, :amount, :user_data, :created_at, :confirmed_at, :counted_at, :discarded_at

  config.sort_order = 'updated_at_desc'
  menu :parent => "Microcredits"

  index do
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
    column :amount, sortable: :amount do |loan|
      number_to_euro loan.amount*100
    end
    column :created_at
    column :confirmed_at
    column :counted_at
    column :discarded_at
    column :returned_at
    actions defaults: true do |loan|    
      if loan.confirmed_at.nil?
        link_to('Confirmar', confirm_admin_microcredit_loan_path(loan), method: :post, data: { confirm: "Por favor, no utilices este botón antes de aparezca el ingreso en la cuenta bancaria. ¿Estas segura de querer confirmar la recepción de este microcrédito?" })
      else
        link_to('Des-confirmar', confirm_admin_microcredit_loan_path(loan), method: :delete, data: { confirm: "¿Estas segura de querer cancelar la confirmación de la recepción de este microcrédito?" })
      end
    end
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
      row :amount do
        number_to_euro microcredit_loan.amount*100
      end
      row :document_vatid
      row :user do
        if microcredit_loan.user and can? :show, microcredit_loan.user
          link_to(microcredit_loan.user.full_name, admin_user_path(microcredit_loan.user))
        else
          "#{microcredit_loan.first_name} #{microcredit_loan.last_name}"
        end
      end
      row :phone do
        if microcredit_loan.user
          microcredit_loan.user.phone
        elsif microcredit_loan.possible_user
          "Posible: #{microcredit_loan.possible_user.phone} (COMPROBAR! #{microcredit_loan.possible_user.full_name} - #{microcredit_loan.possible_user.email})"
        end
      end
      row :email
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
      end
      row :ip if can? :admin, MicrocreditLoan
      row :created_at
      row :confirmed_at
      row :counted_at
      row :discarded_at
      row :returned_at
      if !microcredit_loan.confirmed_at.nil? && microcredit_loan.returned_at.nil?
        next_campaign = Microcredit.non_finished.first
        if next_campaign
          row :renewal_link do
            link_to("Enlace a renovar microcrédito para campaña #{next_campaign.title}", loans_renewal_microcredit_loan_path(next_campaign.id, microcredit_loan.id, microcredit_loan.unique_hash))
          end
        end
      end 
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "Microcrédito" do
      f.input :microcredit
      f.input :user_id
      f.input :amount
      f.input :document_vatid
      f.input :user_data
      f.input :confirmed_at
      f.input :counted_at
      f.input :discarded_at
      f.input :returned_at
    end
    f.actions
  end

  scope :all
  scope :confirmed
  scope :not_confirmed
  scope :counted
  scope :not_counted
  scope :discarded
  scope :not_discarded
  scope :returned
  scope :not_returned
  
  filter :id
  filter :user_last_name_or_user_data_cont, label: "Apellido"
  filter :microcredit
  filter :document_vatid
  filter :created_at
  filter :counted_at
  filter :amount

  action_item(:confirm_loan, only: :show) do
    if microcredit_loan.confirmed_at.nil?
      link_to('Confirmar', confirm_admin_microcredit_loan_path(microcredit_loan), method: :post, data: { confirm: "Por favor, no utilices este botón antes de aparezca el ingreso en la cuenta bancaria. ¿Estas segura de querer confirmar la recepción de este microcrédito?" })
    else
      link_to('Des-confirmar', confirm_admin_microcredit_loan_path(microcredit_loan), method: :delete, data: { confirm: "¿Estas segura de querer cancelar la confirmación de la recepción de este microcrédito?" })
    end
  end

  action_item(:delete, only: :show) do
    if microcredit_loan.discarded_at.nil?
      link_to('Descartar', discard_admin_microcredit_loan_path(microcredit_loan), method: :post, data: { confirm: "¿Estas segura de querer descartar este microcrédito?" })
    end
  end

  action_item(:count_loan, only: :show) do
    if microcredit_loan.counted_at.nil? and microcredit_loan.discarded_at.nil?
      link_to('Mostrar en la web', count_admin_microcredit_loan_path(microcredit_loan), method: :post, data: { confirm: "Por favor, utiliza esta funcionalidad en ocasiones puntuales. Una vez hecho no podrá deshacerse, ¿Estas segura de querer contar este microcrédito en la web?" })
    end
  end

  action_item(:download_pdf, only: :show) do
    link_to('Descargar PDF', download_pdf_admin_microcredit_loan_path(resource))
  end

  member_action :count, :method => [:post] do
    m = MicrocreditLoan.find(params[:id])
    if request.post? and m.counted_at.nil?
      m.counted_at = DateTime.now
    
      if m.save
        flash[:notice] = "El microcrédito ha sido modificado y ahora se cuenta en la web."
      else
        flash[:notice] = "El microcrédito no no ha sido modificado: #{m.errors.messages.to_s}"
      end
    end
    redirect_to :back
  end

  member_action :confirm, :method => [:post, :delete] do
    m = MicrocreditLoan.find(params[:id])
    if request.post? and m.confirmed_at.nil?
      m.discarded_at = nil
      m.confirmed_at = DateTime.now
    elsif request.delete? and not m.confirmed_at.nil?
      m.confirmed_at = nil
    end
    
    if m.save
      m.update_counted_at
      flash[:notice] = "La recepción del microcrédito ha sido confirmada."
    else
      flash[:notice] = "La recepción del microcrédito no ha sido confirmada: #{m.errors.messages.to_s}"
    end
    redirect_to :back
  end

  member_action :discard, :method => :post do
    m = MicrocreditLoan.find(params[:id])
    m.discarded_at = DateTime.now
    m.confirmed_at = nil
    if m.save
      flash[:notice] = "El microcrédito ha sido descartado."
    else
      flash[:notice] = "El microcrédito no ha sido descartado: #{m.errors.messages.to_s}"
    end
    redirect_to :back
  end

  csv do
    column :id
    column :microcredit do |loan|
      loan.microcredit.title
    end
    column :document_vatid
    column :email
    column :first_name
    column :last_name
    column :address
    column :postal_code
    column :town_name
    column :province_name
    column :country_name
    column :amount
    column :created_at
    column :counted_at
    column :confirmed_at
  end

  member_action :download_pdf do
    @loan = MicrocreditLoan.find(params[:id])
    @microcredit = @loan.microcredit

    render pdf: 'IngresoMicrocreditosPodemos.pdf', template: 'microcredit/email_guide.pdf.erb', encoding: "UTF-8"
  end
end
