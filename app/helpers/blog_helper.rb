module BlogHelper
  include AutoHtml
  def formatted_content(post, max_length=nil)
    auto_html(post.content) do
      simple_format
      youtube(width: 400, height: 250)
      vimeo(width: 400, height: 250)
      link(target: "_blank")
      image
    end
  end
end
