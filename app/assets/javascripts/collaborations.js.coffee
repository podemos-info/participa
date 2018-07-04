# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#

calculate_collaboration = () ->
  $amount = $('.js-collaboration-amount option:selected')
  $freq = $('.js-collaboration-frequency option:selected')
  if (($amount.index() > 0) && ($freq.index() > 0))
    total = $amount.val() / 100.0 * $freq.val()
    switch $freq.val()
      when "1"
        message = total + " € cada mes, en total " + total * 12 + " € al año"
      when "3"
        message = total + " € cada 3 meses, en total " + total * 4 + " € al año"
      when "12"
        message = total + " € cada año en un pago único anual"
    $('.js-collaboration-alert').show()
    $('#js-collaboration-alert-amount').text(message)
  else
    $('.js-collaboration-alert').hide()

change_type_frequency = (type_amount) ->
    if (type_amount > 0)
        $('.js-collaboration-type-form-0').show('slide')
      else
        $('.js-collaboration-type-form-0').hide()



change_payment_type = (type) ->
  switch type
    when "2"
      $('.js-collaboration-type-form-3').hide()
      $('.js-collaboration-type-form-2').show('slide')
    when "3"
      $('.js-collaboration-type-form-2').hide()
      $('.js-collaboration-type-form-3').show('slide')
    else
      $('.js-collaboration-type-form-2').hide()
      $('.js-collaboration-type-form-3').hide()


show_assignments = false
update_assigments = () ->
  if (show_assignments)
    $('.js-collaboration-assignment-toggle').hide()
    $('.js-collaboration-assignment').show('slide')
  else
    $('.js-collaboration-assignment').hide('slide')
    $('.js-collaboration-assignment-toggle').show()

init_collaborations = () ->

  must_reload = $('#js-must-reload')

  if (must_reload)
    if (must_reload.val()!="1")
      $("form").on 'submit', (event) ->
        must_reload.val("1")
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

  if ($('.js-collaboration-assignment-toggle').length==0)
    show_assignments = true;

  update_assigments()
  $('.js-collaboration-assignment-autonomy').on 'change', () ->
    update_assigments()

  $('.js-collaboration-assignment-toggle').on 'click', (e) ->
    e.preventDefault()
    show_assignments = true
    update_assigments()

  $('.js-collaboration-assignment-town input').on 'click', () ->
    if ($(this).prop('checked'))
      $('.js-collaboration-assignment-autonomy input').prop('checked', true)
    else
      $('.js-collaboration-assignment-island input').prop('checked', false)

  $('.js-collaboration-assignment-autonomy input').on 'click', () ->
    if (!$(this).prop('checked'))
      $('.js-collaboration-assignment-town input').prop('checked', false)
      $('.js-collaboration-assignment-island input').prop('checked', false)

  $('.js-collaboration-assignment-island input').on 'click', () ->
    if ($(this).prop('checked'))
      $('.js-collaboration-assignment-town input').prop('checked', true)
      $('.js-collaboration-assignment-autonomy input').prop('checked', true)

$(window).bind 'page:change', ->
  init_collaborations()

$ ->
  init_collaborations()
