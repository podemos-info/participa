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

  def bootstrap_class_for_steps(step_n, step_current)
    if step_current == step_n
      "active"
    elsif step_current > step_n
      ""
    else
      "disabled"
    end
  end

  # Like link_to but third parameter is an array of options for current_page?.
  def nav_menu_link_to name, url, current_urls, html_options = {}
    html_options[:class] ||= ""
    html_options[:class] += " active" if current_urls.any? { |u| current_page?(u) }
    link_to content_tag(:span, name), url, html_options
  end

  def new_notifications_class
    # TODO: Implement check if there are any new notifications
    # If so, return "claim"
    ""
  end

  def current_lang? lang
    I18n.locale.to_s.downcase == lang.to_s.downcase
  end

  def current_lang_class lang
    if current_lang? lang
      "active"
    else
      ""
    end
  end
end
