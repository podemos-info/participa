
#init_mobile = () ->
#  if ( navigator.userAgent.match(/Android/i) )
#    $('.js-mobile-bug').show()
#
#    #$('.js-mobile-external').on 'click', (e) ->
#    #  e.preventDefault()
#    #  alert(this.href)
#    #  window.open(this.href, '_system')
#
#$(window).bind 'page:change', ->
#  init_mobile()
#
#$ ->
#  init_mobile()
