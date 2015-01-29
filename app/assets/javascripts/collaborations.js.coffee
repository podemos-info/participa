# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#

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

  must_reload = $('#js-must-reload')
  
  if (must_reload)
    if (must_reload.val()!="1")
      must_reload.val("1")
      $("form").on 'submit', (event) ->
        $("#js-confirm-button").hide()
    else
      must_reload.val("0")
      $("#js-confirm-button").hide()
      location.reload()
    

  change_payment_type($('.js-collaboration-type').val() || $('.js-collaboration-type').select2('val'))

  $('.js-collaboration-type').on 'change', (event) ->
    type = $(this).val()
    change_payment_type(type)

  calculate_collaboration()
  $('.js-collaboration-amount, .js-collaboration-frequency').on 'change', () ->
    calculate_collaboration()


$(window).bind 'page:change', ->
  init_collaborations()

$ ->
  init_collaborations()

