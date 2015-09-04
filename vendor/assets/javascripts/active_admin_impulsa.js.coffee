
$ ->
  $(".reviewable > ol > li").each ->
    input = $("input, textarea", this)[0]
    names = input.name.match(/([^\[]*)\[([^\[]*)\]/)
    if (names!=null)
      review = window.review_fields[names[2]]
      review = "" if (review==undefined)

      parent = $("fieldset", this)
      parent = $(this) if parent.length==0
      
      parent.append("<textarea id='"+names[1]+"_"+names[2]+"_review' placeholder='Añade un comentario para que este campo sea revisado por el usuario' name='"+names[1]+"["+names[2]+"_review]' class='review_field'>"+review+"</textarea>")

  $(".impulsa_project .row").each ->
    name = this.className.match(/row-([^\W]+)/)[1]
    if (window.review_fields[name]!=undefined)
      $(this).prepend("<td class='review'>"+window.review_fields[name]+"</td>")