ActiveAdmin.register MicrocreditLoan do
  actions :all, :except => [:destroy]
  config.per_page = 100

  permit_params :user_id, :microcredit_id, :document_vatid, :amount, :user_data, :created_at, :confirmed_at, :counted_at, :discarded_at, :returned_at, :transferred_to_id, :iban_account, :iban_bic

  config.sort_order = 'updated_at_desc'
  menu :parent => "Microcredits"

  batch_action :destroy, if: proc{can? :admin, MicrocreditLoan}

  index download_links: -> { current_user.is_admin? && current_user.finances_admin? } do
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
    column :document_vatid
    column :amount, sortable: :amount do |loan|
      number_to_euro loan.amount*100
    end
    column :created_at
    column :confirmed_at
    column :counted_at
    column :discarded_at
    column :returned_at
    column :transferred_to do |loan|
      link_to(loan.transferred_to.microcredit.title, admin_microcredit_loan_path(loan.transferred_to)) if loan.transferred_to
    end
    column :original_loans do |loan|
      loan.original_loans.map do |l|
        link_to(l.microcredit.title, admin_microcredit_loan_path(l))
      end.join(" ").html_safe
    end
    actions defaults: true do |loan|
      extra_links=""
      if loan.confirmed_at.nil?
        extra_links << link_to('Confirmar', confirm_admin_microcredit_loan_path(loan), method: :post, data: { confirm:
                                                                                                               "Por favor, no utilices este botón antes de aparezca el ingreso en la cuenta bancaria. ¿Estas segura de querer confirmar la recepción de este microcrédito?" })
      else
        extra_links << link_to('Des-confirmar', confirm_admin_microcredit_loan_path(loan), method: :delete, data: { confirm: "¿Estas segura de querer cancelar la confirmación de la recepción de este microcrédito?" })
      end

      if loan.discarded_at.nil?
        extra_links << link_to('Descartar', discard_admin_microcredit_loan_path(loan), method: :post, data: { confirm:
       "¿Estas segura de querer descartar este microcrédito?" })
      end
      extra_links.html_safe
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
      row :iban_account
      row :iban_bic
      row :ip if can? :admin, MicrocreditLoan
      row :created_at
      row :confirmed_at
      row :counted_at
      row :discarded_at
      row :returned_at
      if microcredit_loan.renewable?
        next_campaign = Microcredit.non_finished.first
        if next_campaign
          row :renewal_link do
            link_to("Enlace a renovar microcrédito para campaña #{next_campaign.title}", loans_renewal_microcredit_loan_path(next_campaign.id, microcredit_loan.id, microcredit_loan.unique_hash))
          end
        end
      end
      if microcredit_loan.transferred_to
        row :transferred_to do |loan|
          link_to(loan.transferred_to.microcredit.title, admin_microcredit_loan_path(loan.transferred_to))
        end
      end
      if microcredit_loan.original_loans.any?
        row :original_loans do |loan|
          loan.original_loans.map do |l|
            link_to(l.microcredit.title, admin_microcredit_loan_path(l))
          end.join(" ").html_safe
        end
      end
      row :updated_at
      row :microcredit_option_id, as: "asignar a" do |loan|
        MicrocreditOption.find(loan.microcredit_option_id).intern_code.to_s + MicrocreditOption.find(loan.microcredit_option_id).name
      end if microcredit_loan.microcredit_option_id.present?
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "Microcrédito" do
      f.input :microcredit
      f.input :user_id
      f.input :amount
      f.input :iban_account
      f.input :iban_bic
      f.input :document_vatid
      f.input :user_data
      f.input :confirmed_at
      f.input :counted_at
      f.input :discarded_at
      f.input :returned_at
      f.input :transferred_to_id
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
  scope :transferred
  scope :renewal
  
  filter :id
  filter :id_in, as: :string, label: "Lista de IDs"
  filter :id_not_in, as: :string, label: "Lista de IDs (excluídos)"
  filter :user_last_name_or_user_data_cont, label: "Apellido"
  filter :microcredit
  filter :document_vatid
  filter :user_email_or_user_data_cont, label: "Email"
  filter :user_email_in, as: :string, label: "Lista de Emails"
  filter :created_at
  filter :counted_at
  filter :amount
  filter :transferred_to_id, as: :select, collection: Microcredit.all
  filter :original_loans_microcredit_id_eq, as: :select, collection: Microcredit.all
  filter :microcredit_option_name, as: :string
  filter :microcredit_option_intern_code, as: :string

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

  batch_action :return_batch, if: proc{ params[:scope]=="confirmed" } do |ids|
    ok = true
    MicrocreditLoan.transaction do
      MicrocreditLoan.where(id:ids).each do |ml|
        ok &&= ml.return!
      end
      redirect_to(collection_path, notice: "Las suscripciones han sido marcadas como devueltas.") if ok
    end

    redirect_to(collection_path, warning: "Ha ocurrido un error y las suscripciones no han sido marcadas como devueltas.") if !ok
  end

  batch_action :confirm_batch, if: proc{ params[:scope]=="not_confirmed" } do |ids|
    ok = true
    MicrocreditLoan.transaction do
      MicrocreditLoan.where(id:ids).each do |ml|
        ok &&= ml.confirm!
      end
      redirect_to(collection_path, notice: "Las suscripciones han sido marcadas como confirmadas.") if ok
    end
    redirect_to(collection_path, warning: "Ha ocurrido un error y las suscripciones no han sido marcadas como confirmadas.") if !ok
  end

  batch_action :discard_batch, if: proc{ params[:scope]=="not_discarded" } do |ids|
    ok = true
    MicrocreditLoan.transaction do
      MicrocreditLoan.where(id:ids).each do |ml|
        ok &&= ml.discard!
      end
      redirect_to(collection_path, notice: "Las suscripciones han sido marcadas como descartadas.") if ok
    end
    redirect_to(collection_path, warning: "Ha ocurrido un error y las suscripciones no han sido marcadas como descartadas.") if !ok
  end

  member_action :count, :method => [:post] do
    m = MicrocreditLoan.find(params[:id])
    if request.post? and m.counted_at.nil?
      m.counted_at = DateTime.now
    
      if m.save
        flash[:notice] = "El microcrédito ha sido modificado y ahora se cuenta en la web."
      else
        flash[:warning] = "El microcrédito no no ha sido modificado: #{m.errors.messages.to_s}"
      end
    end
    redirect_to :back
  end

  member_action :confirm, :method => [:post, :delete] do
    m = MicrocreditLoan.find(params[:id])
    res = false
    if request.post? 
      res = m.confirm!
    elsif request.delete?
      res = m.unconfirm!
    end
    
    if res
      flash[:notice] = "La recepción del microcrédito ha sido confirmada."
    else
      flash[:warning] = "La recepción del microcrédito no ha sido confirmada: #{m.errors.messages.to_s}"
    end
    redirect_to :back
  end

  member_action :discard, :method => :post do
    m = MicrocreditLoan.find(params[:id])
    if m.discard!
      flash[:notice] = "El microcrédito ha sido descartado."
    else
      flash[:warning] = "El microcrédito no ha sido descartado: #{m.errors.messages.to_s}"
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
    column :born_at do |loan|
      loan.user.born_at if loan.user
    end
    column :gender do |loan|
      loan.user.gender if loan.user
    end
    column :address
    column :postal_code
    column :town_name
    column :province_name
    column :country_name
    column :amount
    column :created_at
    column :counted_at
    column :confirmed_at
    column :iban_account
    column :iban_bic

    column :phone do |loan|
      loan.user.phone if loan.user
    end

    column :renewal_link do |loan|
      if loan.renewable?
        next_campaign = Microcredit.non_finished.first
        loans_renewal_microcredit_loan_url(next_campaign.id, loan.id, loan.unique_hash) if next_campaign
      end
    end
    column :microcredit_option_name do |loan|
      loan.microcredit_option.name if loan.microcredit_option_id.present?
    end
    column :microcredit_option_intern_code do |loan|
      loan.microcredit_option.intern_code if loan.microcredit_option_id.present?
    end

    column :transferred_to do |loan|
        loan.transferred_to.microcredit.title if loan.transferred_to
    end
  end

  member_action :download_pdf do
    @loan = MicrocreditLoan.find(params[:id])
    @microcredit = @loan.microcredit
    @brand_config = Rails.application.secrets.microcredits["brands"][Rails.application.secrets.microcredits["default_brand"]]

    render pdf: 'IngresoMicrocreditosPodemos.pdf', template: 'microcredit/email_guide.pdf.erb', encoding: "UTF-8"
  end

  controller do
    before_filter :multiple_id_search, :only => :index

    def multiple_id_search
      params[:q][:id_in] = params[:q][:id_in].split unless params[:q].nil? or params[:q][:id_in].nil?
      params[:q][:id_not_in] = params[:q][:id_not_in].split unless params[:q].nil? or params[:q][:id_not_in].nil?
    end
  end
end
