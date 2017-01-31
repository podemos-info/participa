require 'rubypress'

namespace :podemos do

  desc '[events] Sync projects with WordPress'
  task :export_projects => :environment do
    last_update = Date.today - 1.week
    wp = Rubypress::Client.new  host: Rails.application.secrets.wordpress["host"],
                              username: Rails.application.secrets.wordpress["username"],
                              password: Rails.application.secrets.wordpress["password"]
    loop do
      ImpulsaProject.exportable.where("updated_at>?", last_update).order(updated_at: :asc).each do |project|
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

          post_info[:custom_fields] << { key: "project_email", value: project.user.email }
          post_info[:custom_fields] << { key: "project_evaluation_result", value: project.evaluation_result }
          post_info[:post_name] = post_info[:post_title].parameterize
          post_info[:terms_names][:edition_category] = [ project.impulsa_edition.name, project.impulsa_edition_category.name ]
          
          ret = wp.execute('podemos.saveProject', { project_id: project.id, project: post_info, attachment: attachment } )
          p "S #{project.id} -> #{ret}"
        rescue Exception => ex
          p ex
          Airbrake.notify_or_raise(ex)
        end
        last_update = project.updated_at
      end

      sleep(10.seconds)
    end
  end
end


