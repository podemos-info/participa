ActiveAdmin.register_page "CensusTool" do
  menu :parent => "Users"
  content title:"Herramienta de control de Censo" do
    panel "" do
      render "admin/census_tool/census_tool", width: "100%"
    end
  end

  page_action :search_document_vatid, method: [:post] do
    dt = params["document_type"]
    dn = params["document_vatid"]
    paper_vote_user = User.confirmed.not_banned.where("lower(document_vatid) = ?", dn.downcase).find_by(document_type: dt)
    if paper_vote_user
      message= { notice: "#{paper_vote_user.first_name}, con #{paper_vote_user.document_type_name} #{paper_vote_user.document_vatid}, puede participar." }

    else
      message = { warning: "No se ha encontrado la persona buscada." }

    end
    redirect_to admin_censustool_path, flash: message

  end
end
