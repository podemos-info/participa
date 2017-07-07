init_user_verifications = () ->
  $(".js-user-verification input").bind "change", ->
    if (this.files && this.files[0])
      reader = new FileReader()
      reader.image = jQuery("."+this.id+" img")
      reader.onload = (e) ->
        this.image.attr('src', e.target.result)
      reader.readAsDataURL(this.files[0])

$ ->
  init_user_verifications()

