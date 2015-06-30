update_header = (header) ->
  if (header.checked)
      $(header).closest("li.choice").addClass("checked")
    else
      $(header).closest("li.choice").removeClass("checked")

update_headers = ->
  $(".options_headers li.choice input").each ->
    update_header this

$ ->
  update_headers()

  $(document).on 'cocoon:after-insert', (e, insertedItem) ->
    update_headers()

  $(document).on "click", ".options_headers li.choice input", ->
    update_header this

  $(document).on "click", "a[data-presets]", ->
    p=$(this).closest("li")
    p.next().children(".enable_tabs").val($(this).data("presets").replace(/\|/g, "\n"))
    $("li.choice input", p.prev()).each ->
      this.checked = (this.value=="Text")
      update_header this
    false