require 'mail'

module ActiveModel::Validations
  module EmailValidatorHelpers
    def validate_email value
      return true if value.length==0

      # First check, with the whole string
      if (value.downcase =~ /[ÁÉÍÓÚàèìòùÀÈÍÓÚáéíóúñÑçÇ]/) != nil
        return "no puede contener acentos, eñes u otros caracteres especiales"
      elsif value.include? ".." 
        return "no puede contener dos puntos seguidos"
      elsif (value =~ /^["a-zA-Z0-9]/) == nil
        return "debe comenzar con un número o una letra"
      elsif (value =~ /[a-zA-Z]$/) == nil
        return "debe acabar con una letra"
      else
        begin
          m = Mail::Address.new(value)

          # when an unquoted comma is found, the parsed address is different than the received string
          if value.include? "," and m.address != value
            return "contiene caracteres inválidos"
          elsif not m.domain.include? "." or m.domain.starts_with? "."# domain validation
            return "es incorrecta"
          end
        rescue
          return "es incorrecta"
        end
      end
      false
    end
  end
end

class EmailValidator < ActiveModel::EachValidator
  include ActiveModel::Validations::EmailValidatorHelpers

  def validate_each(record,attribute,value)
    error = validate_email(value)
    if error
      record.errors.delete(attribute)
      record.errors[attribute] << error
      return false
    end
  end
end
