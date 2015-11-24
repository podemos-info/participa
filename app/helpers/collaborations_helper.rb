module CollaborationsHelper
  include ActionView::Helpers::NumberHelper

  def new_or_edit_collaboration_path(collaboration)
    collaboration ? edit_collaboration_path : new_collaboration_path
  end

  def number_to_euro(amount, precision=2)
    number_to_currency(amount/100.0, unit: "€", format: "%n%u", precision:precision)
  end

end
