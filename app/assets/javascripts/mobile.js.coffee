
#init_mobile = () ->
#  if (navigator.userAgent.match(/(iPhone|iPod|iPad|Android|android|BlackBerry|IEMobile)/))
#    $('a[target=_blank]').on 'click', (e) ->
#      e.preventDefault()
#      alert('goin' + this.href)
#      window.open(this.href, '_system')
#
##$(window).bind 'page:change', ->
##  init_mobile()
#
#$ ->
#  init_mobile()
