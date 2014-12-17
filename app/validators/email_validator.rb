require 'mail'

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record,attribute,value)

    # First check, with the whole string
    if (value.downcase =~ /[àèìòùáéíóúñç]/) != nil
      record.errors[attribute] << "La dirección de correo no puede contener acentos, eñes u otros caracteres especiales"
      return false
    elsif value.include? ".." 
      record.errors[attribute] << "La dirección de correo no puede contener dos puntos seguidos"
      return false
    elsif (value =~ /^[a-zA-Z0-9]/) == nil
      record.errors[attribute] << "La dirección de correo debe comenzar con un número o una letra"
      return false
    elsif (value =~ /[a-zA-Z]$/) == nil
      record.errors[attribute] << "La dirección de correo debe acabar con una letra"
      return false
    end

    begin
      m = Mail::Address.new(value)

      # domain validation
      if m.domain.include? "," or not m.domain.include? "."
        record.errors[attribute] << "La dirección de correo contiene caracteres inválidos"
        return false
      end

      # name validation
      if m.name.include? "," and (not m.name.start_with '"' or not m.name.end_with '"')
        record.errors[attribute] << "La dirección de correo contiene caracteres inválidos"
        return false
      end

    rescue Exception => e   
      record.errors[attribute] << "La dirección de correo no es correcta"
      r = false
    end
  end
end