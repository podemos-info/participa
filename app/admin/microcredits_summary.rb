ActiveAdmin.register_page "microcredits_summary" do

  menu parent: "microcredits", label: "Resumen de microcréditos"

  content title: "Resumen de microcréditos" do
    panel "Evolución €" do
      render "admin/microcredits_amounts", width: "80%"
    end
    panel "Evolución #" do 
      render "admin/microcredits_count", width: "80%"
    end
  end

  controller do
    private

    def authorize_access!
      authorize! :read, Microcredit
    end
  end

end
