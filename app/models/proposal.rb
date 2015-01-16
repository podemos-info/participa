require 'open-uri'
class Proposal
  include ActiveModel::Model
  attr_accessor :title, :description, :reddit_url, :reddit_id

  def self.reddit_url
    type = 'hot'
    url_base = 'http://api.reddit.com/r/Podemos/search?q=flair%3APropuestas&sort='
    url_base + type + '&restrict_sr=on&t=all&limit=' + '10'    
  end

  def self.reddit_proposals    
    parse(JSON.load(open(reddit_url))["data"]["children"])
  end

  def self.parse(json)
    json.collect {|proposal| 
      Proposal.new(title:       proposal["data"]["title"],
                   description: proposal["data"]["selftext"],)
    }
  end
end