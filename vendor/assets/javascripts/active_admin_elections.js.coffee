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


$ ->
  $(".js-election-graph").each ->
    graph = $(this)

    d3.json graph.data("url"), (error, data) ->
      if error 
        throw error

      padding = 50
      height = graph.data("height")
      width = graph.parent().width()
      xlimits = data["limits"][0]
      x = d3.scaleTime().domain([ new Date(xlimits[0]*1000), new Date((xlimits[1])*1000)]).range([ padding, width-padding ])
      ylimits = data["limits"][1]
      y = d3.scaleTime().domain([ new Date(ylimits[0]*1000), new Date((ylimits[1])*1000)]).range([ padding, height-padding ])
      z = d3.scaleSequential(d3.interpolateWarm)

      svg = d3.select(graph.get(0))
      svg.attr("width", width).attr("height", height)
      svg.append("g").attr("transform", "translate("+padding+",0)").call(d3.axisLeft(y))
      svg.append("g").attr("transform", "translate(0, "+(height-padding)+")").call(d3.axisBottom(x))
      svg.append("g").selectAll("circle").data(data["data"]).enter().append("circle").attr("r", 1)
        .attr "cx", (d)->
          x(new Date(d[0]*1000))
        .attr "cy", (d)->
          y(new Date(d[1]*1000))
        .attr "fill", (d)->
          z(d[2])
