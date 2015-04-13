get_totals = ->
  totals = ($(item).data("amount") * parseInt($(item).val()) for item in $('.single_limits'))
  totals.reduce (a, b) -> return a + b

$ ->
  microcredit_phase_limit_amount = $('#microcredit_phase_limit_amount')

  if (microcredit_phase_limit_amount.length>0)
    microcredit_phase_limit_amount.val(get_totals())
    $('.single_limits').on "change", ->
      microcredit_phase_limit_amount.val(get_totals())