def export name, total, col_sep="\t", force_quotes=false
  elections = Election.all.order(id: :asc)
  CSV.open( "tmp/export/#{name}.csv", 'w', { col_sep: col_sep, encoding: 'utf-8', force_quotes: force_quotes} ) do |writer|
    elections.each do |e|
      total[e.id].each do |town, totals|
        u = User.new vote_town: town
        writer << [ e.id, town, totals[:inscritos], totals[:activos], totals[:votos], e.title, u.vote_town_name, u.vote_province_name, u.vote_autonomy_name ]
      end
    end
  end
end

namespace :podemos do
  desc "[podemos] Elections stats"
  task :election_stats, [:ids] => :environment do |t, args|
    args.with_defaults(:ids => "")

    election_ids = args.ids.split(",")

    batch_size = 1000
    progress = RakeProgressbar.new(User.with_deleted.count)
    
    i=0
    total=Hash.new do |h1,k1| 
      h1[k1] = Hash.new do |h2,k2| 
        h2[k2] = Hash.new do |h3,k3|
          h3[k3] = 0 
        end
      end
    end

    elections = (election_ids.any? ? Election.where(id:election_ids) : Election.all).order(id: :asc)

    max_id = 0
    votes = {}
    User.with_deleted.includes(:versions).find_each(batch_size:batch_size) do |u|
      if u.id>max_id
        max_id = u.id+batch_size
        votes = Hash.new {|h,k| h[k] = {} }
        Vote.with_deleted.where("user_id between ? and ?", u.id, max_id).each do |v|
          votes[v.election_id][v.user_id] = 1
        end
      end

      i+=1
      
      elections.each do |e|
        lsd = e.ends_at - 1.year
        next if u.created_at > e.ends_at

        user = e.user_version(u)
        user = u.version_at(e.ends_at) if user==u
        next if user.nil? || !user.deleted_at.nil? || user.sms_confirmed_at.nil? || user.banned?

        town = "-"
        if user.vote_town
          town = user.vote_town.downcase
          town = "-" if town[0..1]!="m_"
        end

        if votes[e.id][u.id]
          total[e.id][town][:inscritos] += 1
          total[e.id][town][:activos] += 1
          total[e.id][town][:votos] += 1
        elsif e.has_valid_user_created_at?(user) && (e.scope==0 || e.has_valid_location_for?(user))
          total[e.id][town][:inscritos] += 1
          total[e.id][town][:activos] += 1 if user.current_sign_in_at && user.current_sign_in_at > lsd
        end
      end
      progress.inc
      
      if i%100==0
        export("election-stats-#{i}", total) if i%1000==0
      end
    end

    export("election-stats", total)
    progress.finished
  end
end