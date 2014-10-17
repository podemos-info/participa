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

  def info_box &block
    content = with_output_buffer(&block)
    render partial: 'info', locals: { content: content }
  end

  # Renders an alert with given title,
  # text for close-button and content given in
  # a block.
  def alert_box title, close_text="", &block
    render_flash 'alert', title, close_text, &block
  end

  # Renders an error with given title,
  # text for close-button and content given in
  # a block.
  def error_box title, close_text="", &block
    render_flash 'error', title, close_text, &block
  end

  # Generalization from render_alert and render_error
  def render_flash partial_name, title, close_text="", &block
    content = with_output_buffer(&block)
    render partial: partial_name, locals: {title: title, content: content, close_text: close_text}
  end

  def field_notice_box
    render partial: 'form_field_notice'
  end

  def errors_in_forms resource
    render partial: 'errors_in_form', locals: {resource: resource}
  end

  def steps_nav current_step, *steps_text
    render partial: 'steps_nav',
           locals: { first_step: steps_text[0],
                     second_step: steps_text[1],
                     third_step: steps_text[2],
                     steps_text: steps_text,
                     current_step: current_step }
  end
end
