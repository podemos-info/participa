$(document).on 'ready', ->
	$('.impulsa input[type=file]').each (i, element) ->
    $element = $(element)
    context = $element.closest(".inputlabel-box")

    $element.fileupload {
                  url: $(".file", context).data("url")
                  dataType: 'json'
                  dropZone: context
                  paramName: 'file'
                  drop: (e, data) ->
                    $(".file-data .current-file", context).fadeOut(50)
                    $(".file-data .progress", context).fadeIn(1)
                  change: (e, data) ->
                    $(".file-data .current-file", context).fadeOut(50)
                    $(".file-data .progress", context).fadeIn(1)
                  done: (e, data) ->
                    file = data.result
                    $(".file.input.has-error", context).removeClass("has-error").removeClass("error")
                    $(".file-data a.download", context).text(file.name)
                    $(".file-data a.download", context).attr("href", file.path)
                    $(".file-data a.delete", context).removeClass("hidden")
                    $('.file-data .progress', context).fadeOut(50)
                    $(".file-data .current-file", context).fadeIn(50)
                  fail: (e, data) ->
                    alert "Han ocurrido los siguientes errores: \n" + data.jqXHR.responseJSON.map((i) -> return " * "+i).join("\n")
                    $('.file-data .progress', context).fadeOut(50)
                  progressall: (e, data) ->
                    progress = parseInt data.loaded/data.total * 100, 10
                    $('.progress .progress-bar', context).css 'width', progress + '%'
                }
    $element.prop('disabled', !$.support.fileInput)
    context.addClass($.support.fileInput ? undefined : 'disabled')

  $(".impulsa .file-data a.delete").on "ajax:success", (e) ->
    $(this).closest(".file-data .current-file").fadeOut(50)