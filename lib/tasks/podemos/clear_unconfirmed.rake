namespace :podemos do
  desc "[podemos] Remove users with unconfirmed email after an elapsed time"
  task :clear_unconfirmed => :environment do
    max_unconfirmed_hours = Rails.application.secrets.users["max_unconfirmed_hours"]
    User.where(confirmed_at:nil).where("confirmation_sent_at < ?", DateTime.now-max_unconfirmed_hours.hours).destroy_all
  end
end
