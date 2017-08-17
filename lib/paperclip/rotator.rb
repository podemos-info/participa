module Paperclip
  class Rotator < Thumbnail
    def transformation_command
      if rotate_command
         rotate_command + super.join(' ')
      else
        super
      end
    end

    def rotate_command
      target = @attachment.instance
      " -rotate #{target.rotate[@attachment.name]} " if target.respond_to?(:rotate) && target.rotate[@attachment.name].present?
    end
  end
end