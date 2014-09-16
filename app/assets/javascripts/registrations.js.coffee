
# https://github.com/jim/carmen-demo-app#readme 
subregion_change = ($country_select) ->
  select_wrapper = $('#js-registration-subregion-wrapper')
  $('select', select_wrapper).attr('disabled', true)
  country_code = $country_select.val()
  url = "/registrations/subregion_options?parent_region=#{country_code}"
  select_wrapper.load(url)

document_change = (document_type) ->
  $('.js-registration-document-wrapper').removeClass('hidden')
  $('.js-registration-document-wrapper label').html("#{document_type} <abbr title='required'>*</abbr>")

  switch document_type
    when "DNI/NIE" then has_dni()
    when "Pasaporte" then has_passport()
    else has_dni()

has_dni = () ->
  # TODO 
  $('.js-registration-document-passport').addClass('hidden')

has_passport = () ->
  $('.js-registration-document-passport').removeClass('hidden')

init_registrations = () ->
  # change to subregion on first load
  subregion_change($('select.js-registration-country'))

  # change to subregion on country change
  $('select.js-registration-country').change (event) ->
    subregion_change($(this))

  if ( $('.js-registration-document:checked').length > 0 )
    document_type = $('.js-registration-document:checked').parents('label').text()
    document_change(document_type)

  $('.js-registration-document').change (event) ->
    document_type = $(this).parents('label').text()
    document_change(document_type)

$(window).bind 'page:change', ->
  init_registrations()

$ ->
  init_registrations()

