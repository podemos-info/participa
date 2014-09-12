module ApplicationHelper

  # https://gist.github.com/roberto/3344628 
  def bootstrap_class_for flash_type
    case flash_type.to_sym
    when :success
      "alert-success"
    when :error
      "alert-danger"
    when :alert
      "alert-warning"
    when :notice
      "alert-info"
    else
      flash_type.to_s
    end
  end

  def bootstrap_nav_link(text, path, icon)
    options = current_page?(path) ? { class: "active" } : {}
    content_tag(:li, options) do
      link_to content_tag(:i, "", class: "glyphicon #{icon}") + " " + text, path
    end
  end

end
