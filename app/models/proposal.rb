require 'open-uri'
class Proposal
  include ActiveModel::Model
  attr_accessor :title, :description, :reddit_url, :reddit_id
    
  def self.base_url
    "http://api.reddit.com"
  end
    
  def self.reddit_proposal(id)
    url = "#{base_url}/by_id/#{id}"
    parse(url).first
  end

  def self.reddit_proposals(filter='hot')
    url = "#{base_url}/r/Podemos/search?q=flair%3APropuestas&sort=#{filter}&restrict_sr=on&t=all&limit=10"
    parse(url)
  end

  def self.parse(url)
    json = JSON.load(open(url))["data"]["children"]
    json.collect {|proposal| 
      data = proposal["data"]
      Proposal.new(title:       data["title"],
                   description: data["selftext"],
                   reddit_url:  data["url"],
                   reddit_id:   data["name"])
    }
  end
end