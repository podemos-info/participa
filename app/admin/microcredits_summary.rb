ActiveAdmin.register_page "microcredits_summary" do

  menu parent: "microcredits", label: "Resumen de microcréditos"

  content title: "Resumen de microcréditos" do
    panel "Evolución" do
      render "admin/microcredits_history"
    end
  end

end
