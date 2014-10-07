module CollaborationsHelper

  def new_or_edit_collaboration_path(collaboration)
    collaboration ? edit_collaboration_path : new_collaboration_path
  end

  def number_to_euro(amount)
    number_to_currency(amount/100.0, unit: "€", format: "%n %u")
  end

end
