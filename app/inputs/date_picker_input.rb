class DatePickerInput < Formtastic::Inputs::StringInput

  def input_html_options
    super.merge(:value => object.born_at.strftime("%d/%m/%Y"))
  end

  def wrapper_html_options
    super.merge(:class => "date")
  end

end
