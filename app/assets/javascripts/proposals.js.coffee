$ ->
  $("form.new_support").bind "ajax:error", (event, jqXHR, ajaxSettings, thrownError) ->
    if jqXHR.status == 401
      window.location.replace('/users/sign_in')