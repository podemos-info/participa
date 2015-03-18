require 'open-uri'
class Reddit
  attr_accessor :base_url, :filter, :limit
  
  def initialize(name)
    @base_url = "http://api.reddit.com/r/#{name}"
    @filter   = 'top'
    @limit    = 100
  end

  def extract
    proposals(url).each {|proposal| create_or_update(proposal) }
  end

  def url
    "#{@base_url}/search?q=flair%3APropuestas&sort=#{@filter}" + 
    "&restrict_sr=on&t=all&limit=#{@limit}"
  end

  def proposals(url)
    JSON.load(open(url))["data"]["children"]
  end

  def create_or_update(proposal)
    params = map(proposal['data'])
    Proposal.where(reddit_id: params[:reddit_id]).first_or_initialize.
    update_attributes!(params)
  end

  def map(data)
    { title:       data["title"],
      description: data["selftext"],
      votes:       data["ups"],
      author:      data["author"],
      reddit_url:  data["url"],
      reddit_id:   data["name"] }
  end
end