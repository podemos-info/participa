namespace :podemos do

  desc "[podemos] Generate orders for collaborations for a specific month"
  task :generate_orders, [:month, :year] => :environment do |t, args|
    args.with_defaults(:month => Date.today.month, :year => Date.today.year)

    date = DateTime.new(args.year.to_i, args.month.to_i, Rails.application.secrets.orders["creation_day"].to_i)
    Collaboration.find_each do |collaboration|
      collaboration.generate_order date
    end
  end
end

#colaboraciones mensuales/trimestrales/anuales
# - traerse ultima orden 
# - generar nueva, si corresponde



