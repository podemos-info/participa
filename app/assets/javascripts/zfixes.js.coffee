# FIX: 
# overriding select2 placeholder bug with Formtastic-Bootstrap until it's fixed upstream
#
# https://github.com/mjbellantoni/formtastic-bootstrap/issues/80 
#
# If this isn't here, then you'll see ".col-xs-3 .col-xs-5 .col-xs-4" as placeholders

born_at_format = () ->
  if ( $('#select2-chosen-2').html() == ".col-xs-3" )
    $('#select2-chosen-2').html('día')
  if ( $('#select2-chosen-3').html() == ".col-xs-5" )
    $('#select2-chosen-3').html('mes')
  if ( $('#select2-chosen-4').html() == ".col-xs-4" )
    $('#select2-chosen-4').html('año')

init_zfixes = () ->
  born_at_format()


$(window).bind 'page:change', ->
  init_zfixes()

$ ->
  init_zfixes()


