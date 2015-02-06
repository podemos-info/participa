colors=['#c3a6cf','#954e99','#612d62','#97c2b8','#269283']

draw_pie_chart = ($el, data, template) ->
  ctx = $el.get(0).getContext("2d")
  options = {
    legendTemplate : template,
    percentageInnerCutout : 50,
    animationEasing: "easeInOutCubic"
  }
  piechart = new Chart(ctx).Pie(data,options)
  $el.after(piechart.generateLegend())
  
$ ->
  graph = $(".js-col-total-graph")
  if graph.length>0
    vs = $('.js-col-total', graph)
    parts = ({ value: parseInt($(v).html()), color:colors[Math.round(2*_i/vs.length)], highlight: colors[0], label: $(v).attr("alt") } for v in vs)
    parts.unshift({ value: parseInt($('.js-col-current').html()), color:colors[4], highlight: colors[3], label: $('.js-col-current').attr("alt") })

    draw_pie_chart( $('canvas',graph), parts, "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<segments.length; i++){%><li><span style=\"background-color:<%=segments[i].fillColor%>\"><%if(segments[i].label){%><%=segments[i].label%></span><%}%></li><%}%></ul>")

    $(".js-col-graph").each (i,graph) ->
      draw_pie_chart( $('canvas',graph), [
        { value: parseInt($('.js-col-current',graph).html()), color:colors[4], highlight: colors[3], label: "Suscritos" },
        { value: parseInt($('.js-col-pending',graph).html()), color:colors[2], highlight: colors[0], label: "Restantes" }
      ], "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<segments.length; i++){%><li><span style=\"background-color:<%=segments[i].fillColor%>\"><%if(segments[i].label){%><%=segments[i].label%> (<%=segments[i].value%>)</span><%}%></li><%}%></ul>")
    $(".hide").hide()