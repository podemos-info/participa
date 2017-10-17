require 'rubypress'

namespace :podemos do

  desc '[events] Sync projects with WordPress'
  task :export_projects => :environment do
    last_update = Date.today - 7.year
    wp = Rubypress::Client.new  host: Rails.application.secrets.wordpress["host"],
                              username: Rails.application.secrets.wordpress["username"],
                              password: Rails.application.secrets.wordpress["password"]
    loop do
      ImpulsaProject.exportable.where("updated_at>?", last_update).order(id: :asc).each do |project|
        begin
          attachment = nil
          post_info = {
                        post_status: "publish",
                        post_date: project.created_at.gmtime,
                        post_title: project.name,
                        custom_fields: [],
                        terms_names: {}
                      }

          project.wizard_export.each do |key, value|
            if key=="wizard_title"
              post_info[:post_title] = value
            elsif key=="wizard_description"
              post_info[:post_content] = value
            elsif key=="wizard_attachment"
              path = project.files_folder+value
              attachment = { name: File.basename(value),
                            type: MIME::Types.type_for(path).first.to_s,
                            bits: XMLRPC::Base64.new(IO.read(path)),
                            digest: Digest::SHA1.file(path).hexdigest
                            }
            elsif value.is_a? Array
              post_info[:terms_names][key] = value
              post_info[:custom_fields] << { key: "project_#{key}", value: value }
            else
              post_info[:custom_fields] << { key: "project_#{key}", value: value }
            end
          end

          project.evaluation_export.each do |key, value|
            post_info[:custom_fields] << { key: "project_#{key}", value: value }
          end
          pr_category = project.impulsa_edition_category.name.split(" ").slice(0)
          pr_category2 = project.impulsa_edition_category.name.split(" - ").slice(0)
          pos = pr_category == "HACEMOS" ? 1: pr_category2 == "Impulsa tu entorno" ? 4 : 5
          pr_territory = project.impulsa_edition_category.name.split(" ").slice(pos)
          post_info[:custom_fields] << { key: "project_territory", value: pr_territory ? pr_territory : "" }
          post_info[:custom_fields] << { key: "project_email", value: project.user ? project.user.email : project.wizard_values["autoridad.email_contacto"] ? project.wizard_values["autoridad.email_contacto"] : project.wizard_values["persona.email"] ? project.wizard_values["persona.email"] :project.wizard_values["circulo.email"] }
          post_info[:custom_fields] << { key: "project_evaluation_result", value: project.evaluation_result ? project.evaluation_result : "" }
          post_info[:post_name] = post_info[:post_title].parameterize
          post_info[:terms_names][:edition_category] = [ project.impulsa_edition.name, project.impulsa_edition_category.name ]
          
          ret = wp.execute('podemos.saveProject', { project_id: project.id, project: post_info, attachment: attachment } )
          p "S #{project.id} -> #{ret}"
        rescue Exception => ex
          p "ERROR IN #{project.id} -> #{ex}"
        end
        last_update = project.updated_at
      end

      sleep(10.seconds)
    end
  end
end


