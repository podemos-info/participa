# extracted from https://github.com/mariohmol/paperclip-keeponvalidation
module ActiveRecord
  class Base

    def decrypt(data)
      return '' unless data.present?
      cipher = build_cipher(:decrypt, 'mypassword')
      cipher.update(Base64.urlsafe_decode64(data).unpack('m')[0]) + cipher.final
    end
  
    def encrypt(data)
      return '' unless data.present?
      cipher = build_cipher(:encrypt, 'mypassword')
      Base64.urlsafe_encode64([cipher.update(data) + cipher.final].pack('m'))
    end
  
    def build_cipher(type, password)
      cipher = OpenSSL::Cipher::Cipher.new('DES-EDE3-CBC').send(type)
      cipher.pkcs5_keyivgen(password)
      cipher
    end
    
    #ex: @avatar_cache = cache_files(avatar,@avatar_cache,lambda {|f| assign_attributes(avatar: f)})
    def cache_files(field, field_cache, execute = {})
      if field.queued_for_write[:original] && errors[field.name].blank?
        FileUtils.mkdir_p(File.dirname(field.path(:original)))
        FileUtils.cp(field.queued_for_write[:original].path, field.path(:original))
        field_cache = encrypt(field.path(:original))
      elsif field_cache.present?
        File.open(decrypt(field_cache)) {|f| execute.call(f) }
      end
      return field_cache
    end
  end
end

module Paperclip
  module Interpolations
    def field attachment, style_name
      attachment.name.to_s.downcase
    end
  end
end