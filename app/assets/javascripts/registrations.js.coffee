
# https://github.com/jim/carmen-demo-app#readme 
subregion_change = ($country_select) ->
  select_wrapper = $('#js-registration-subregion-wrapper')
  $('select', select_wrapper).attr('disabled', true)
  country_code = $country_select.val()
  url = "/registrations/subregion_options?parent_region=#{country_code}"
  select_wrapper.load(url)

$ ->
  # change to subregion on first load
  subregion_change($('select.js-registration-country'))

  # change to subregion on country change
  $('select.js-registration-country').change (event) ->
    subregion_change($(this))
