require 'mail'

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record,attribute,value)

    if value.length==0
      return true
    end

    error = false

    # First check, with the whole string
    if (value.downcase =~ /[ÁÉÍÓÚàèìòùÀÈÍÓÚáéíóúñÑçÇ]/) != nil
      error = "La dirección de correo no puede contener acentos, eñes u otros caracteres especiales"
    elsif value.include? ".." 
      error = "La dirección de correo no puede contener dos puntos seguidos"
    elsif (value =~ /^["a-zA-Z0-9]/) == nil
      error = "La dirección de correo debe comenzar con un número o una letra"
    elsif (value =~ /[a-zA-Z]$/) == nil
      error = "La dirección de correo debe acabar con una letra"
    else
      begin
        m = Mail::Address.new(value)

        # when an unquoted comma is found, the parsed address is different than the received string
        if value.include? "," and m.address != value
          error = "La dirección de correo contiene caracteres inválidos"
        elsif not m.domain.include? "." or m.domain.starts_with? "."# domain validation
          error = "La dirección de correo es incorrecta"
        end
      rescue
        error = "La dirección de correo es incorrecta"
      end
    end

    if error
      record.errors.delete(attribute)
      record.errors[attribute] << error
      return false
    end
  end
end
