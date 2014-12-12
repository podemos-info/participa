namespace :podemos do

  desc "[podemos] Generate orders for collaborations for a specific month"
  task :generate_orders, [:month, :year] => :environment do |t, args|
    args.with_defaults(:month => Date.today.month, :year => Date.today.year)

    date = DateTime.civil args.year.to_i, args.month.to_i
    Collaboration.find_each do |collaboration|
      if not collaboration.order_for_period(date)
        Order.create(collaboration: collaboration, payable_at: date)
      end
    end
  end
end

#colaboraciones mensuales/trimestrales/anuales
# - traerse ultima orden 
# - generar nueva, si corresponde



