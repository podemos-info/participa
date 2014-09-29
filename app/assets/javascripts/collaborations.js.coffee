# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#

open_redsys_window = () ->
  vent = window.open("", "tpv", "width=725,height=600,scrollbars=no,resizable=yes,status=yes,menubar=no,location=no")
  document.forms[0].submit()
  return
  #$('.js-collaboration-form').submit()


show_collaboration_ajax_loader = () ->
  $('.js-collaboration-confirm').attr('disabled', 'disabled')
  $('.js-collaboration-confirm-ajax').show().removeClass('hide')

check_collaboration_by_ajax = () ->
  order = $('.js-collaboration-order').attr('value')
  timeOutId = 0
  ajaxFn = ->
    $.ajax
      url: "/collaborations/validate/status/" + order
      success: (response) ->
        if response.status?
          switch response.status
            when "OK"
              window.location = "/collaborations/validate/OK"
              clearTimeout timeOutId
            when "KO"
              window.location = "/collaborations/validate/KO"
              clearTimeout timeOutId
            else
              window.location = "/collaborations/validate/KO"
              clearTimeout timeOutId
        else
          timeOutId = setTimeout(ajaxFn, 10000)
          console.log "call"
        return

    return
  #ajaxFn()
  #OR use BELOW line to wait 10 secs before first call
  timeOutId = setTimeout(ajaxFn, 10000)

start_collaboration_confirm = () ->
  show_collaboration_ajax_loader()
  open_redsys_window()
  check_collaboration_by_ajax()

init_collaborations = () ->
  $('.js-collaboration-confirm').on 'click', (event) ->
    event.preventDefault()
    start_collaboration_confirm()

$(window).bind 'page:change', ->
  init_collaborations()

#$ ->
#  init_collaborations()

