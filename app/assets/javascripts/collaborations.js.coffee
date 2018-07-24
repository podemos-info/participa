# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
#= require jquery-maskmoney/dist/jquery.maskMoney

calculate_collaboration = () ->
  $freq = $('.js-collaboration-frequency option:selected')
  if $freq.index() > 0
    amount = $('#collaboration_amount').val()
    total = amount / 100.0
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

change_type_frequency = (type) ->
  switch type
    when "recursive"
      $('.frequency').show('slide')
    else
      $('.frequency').hide()



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
  $('#collaboration_amount, #collaboration_frequency').on 'change', () ->
    calculate_collaboration()

  if ($('.js-collaboration-assignment-toggle').length==0)
    show_assignments = true;

  update_assigments()
  $('.js-collaboration-assignment-autonomy').on 'change', () ->
    update_assigments()

  $('#collaboration_amount_holder').maskMoney({thousands: '.', decimal: ',', suffix: ' €'})
  $('#collaboration_amount_collector').on 'change', (e) ->
    if this.value == '0'
       $('.amount').show()
    else
       $('.amount').hide()
    $('#collaboration_amount').val(this.value)
  $('#collaboration_amount_holder').on 'change', (e) ->
    amount = this.value.replace(' €', '').replace('.', '').replace(',','')
    console.log amount
    $('#collaboration_amount').val(amount)

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

  change_type_frequency($('.js-collaboration-type-amount').val() || "single")

  $('.js-collaboration-type-amount').on 'change', () ->
    type = $(this).val()
    change_type_frequency(type)

$(window).bind 'page:change', ->
  init_collaborations()

$ ->
  init_collaborations()
