ActiveAdmin.register_page "CensusTool" do
  menu :parent => "Users"
  content title:"Herramienta de control de Censo" do
    panel "" do
      render partial: 'admin/census_tool/qr_scanner' if Rails.application.secrets[:qr_enabled]
      render partial: "admin/census_tool/census_tool" #, layout:false, width: "100%"
    end
  end

  page_action :search_document_vatid, method: [:post] do
    sv = params["decoding_index"]
    dt = params["document_type"]
    dn = params["document_vatid"]
    qr_hash = params["user_qr_hash"]
    paper_vote_user = User.confirmed.not_banned.militant.where(vote_circle_id:current_user.vote_circle_id).where("lower(document_vatid) = ?", dn.downcase).find_by(document_type: dt)
    if paper_vote_user && (qr_hash.empty? || check_verified_user_hash(dn,qr_hash))
      message= { qr_success: "#{paper_vote_user.first_name}, con #{paper_vote_user.document_type_name} #{paper_vote_user.document_vatid}, puede participar." }
      result = "correct"
    else
      message = { qr_wrong: "No se ha encontrado la persona buscada." }
      result = "wrong"
    end
    redirect_to admin_censustool_path(result: result, decoding_index: sv), flash: message
  end

  controller do
    def check_verified_user_hash(document_vatid,received_hash)
      user = User.find_by_document_vatid(document_vatid)
      user ? user.is_qr_hash_correct?(received_hash) : false
    end
  end
end
