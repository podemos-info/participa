module BlogHelper
  include AutoHtml
  def formatted_content(post, paraphs=nil)
    content = if paraphs then post.content.split("\n")[0..(paraphs-1)].join("\n") else post.content end
    auto_html(content) do
      twitter
      youtube
      vimeo
      image
      link target: "_blank"
      simple_format sanitize: false
    end
  end

  def main_media post
    auto_html(post.media_url) do
      youtube
      vimeo
      image
    end if post.media_url
  end

  def long_date post
    I18n.l post.created_at.to_date, format: :long
  end
end
