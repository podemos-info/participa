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
  $('.js-collaboration-confirm-buttons').hide()
  $('.js-collaboration-confirm-ajax').show()

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
        return

    return
  #ajaxFn()
  #OR use BELOW line to wait 10 secs before first call
  timeOutId = setTimeout(ajaxFn, 10000)

start_collaboration_confirm = () ->
  show_collaboration_ajax_loader()
  open_redsys_window()
  check_collaboration_by_ajax()

calculate_collaboration = () ->
  $amount = $('.js-collaboration-amount option:selected')
  $freq = $('.js-collaboration-frequency option:selected')
  if (($amount.length > 0) && ($freq.length > 0))
    total = $amount.val() / 100.0 * $freq.val()
    switch $freq.val()
      when "1"
        message = total + " € cada mes, en total " + total * 12 + " € al año"
      when "3"
        message = total + " € cada 3 meses, en total " + total * 4 + " € al año"
      when "12"
        message = total + " € cada año en un pago único anual"
    $('#js-collaboration-alert-amount').text(message)

change_payment_type = (type) ->
  switch type
    when "2"
      $('.js-collaboration-type-form-3').hide()
      $('.js-collaboration-type-form-2').show('fast')
    when "3"
      $('.js-collaboration-type-form-2').hide()
      $('.js-collaboration-type-form-3').show('fast')
    when "1"
      $('.js-collaboration-type-form-2').hide()
      $('.js-collaboration-type-form-3').hide()
    else
      $('.js-collaboration-type-form-2').hide()
      $('.js-collaboration-type-form-3').hide()

init_collaborations = () ->

  change_payment_type($('.js-collaboration-type:selected').val())
  $('.js-collaboration-type').on 'change', (event) ->
    type = $(this).val()
    change_payment_type(type)

  #$('.js-collaboration-confirm').on 'click', (event) ->
  #  event.preventDefault()
  #  start_collaboration_confirm()

  calculate_collaboration()
  $('.js-collaboration-amount, .js-collaboration-frequency').on 'change', () ->
    calculate_collaboration()


#$(window).bind 'page:change', ->
#  init_collaborations()

$ ->
  init_collaborations()

