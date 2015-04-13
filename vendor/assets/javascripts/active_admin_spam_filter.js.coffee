
load_filter_users = (offset, total, progress_label, users_div) ->
  limit = 1000
  
  $.ajax({
    url: "more?offset="+offset+"&limit="+limit
  }).done (response) ->
    users_div.append(response)
    offset += limit
    if (offset>=total)
      progress_label.text(total)
    else
      progress_label.text(offset)
      load_filter_users(offset, total, progress_label, users_div)

$ ->
  spam_filter_progress = $('#js-spam-filter-progress')

  if (spam_filter_progress.length>0)
    spam_filter_users = $('#js-spam-filter-users')
    spam_filter_total = parseInt($('#js-spam-filter-total').text())
    load_filter_users(0, spam_filter_total, spam_filter_progress, spam_filter_users)
