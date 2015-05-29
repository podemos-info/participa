module BlogHelper
  include AutoHtml
  def formatted_content(post, max_paraphs=nil)
    read_more = nil
    content = post.content
    if max_paraphs
      paraphs = content.split("\n", max_paraphs+1)
      if paraphs.length>max_paraphs
        content = paraphs[0..(max_paraphs-1)].join("\n")
        read_more = content_tag(:p, link_to(fa_icon("plus-circle", text:'Seguir leyendo'), post))
      end
    end

    [ auto_html(content) do
      redcarpet
      twitter
      youtube
      vimeo
      image
      link target: "_blank"
      simple_format
    end, read_more ].compact.sum
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
