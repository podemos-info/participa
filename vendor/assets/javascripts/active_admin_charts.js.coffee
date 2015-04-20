all = (i,alpha) ->
  "rgba("+["195,166,207", "149,78,153", "97,45,98", "38,146,131", "151,194,184", "100,100,100"][i%6]+","+alpha+")"

purple = (i,alpha) ->
  "rgba("+["195,166,207", "149,78,153", "97,45,98"][i%3]+","+alpha+")"

text = (i) ->
  [ "black", "black", "white" ][i%2]
green = (i,alpha) ->
  "rgba("+["38,146,131", "151,194,184"][i%2]+","+alpha+")"


String::to_i = ->
  parseInt(this.replace(/€/g,"").replace(/\./g,"").replace(/,/g,".").trim())

draw_chart = ($el) ->
  ctx = $el.get(0).getContext("2d")
  scope = $el.data("scope")
  pie = $el.hasClass("pie")

  options = {
    percentageInnerCutout : 20,
    animationEasing: "easeInOutCubic",
    bezierCurveTension : 0.2,
    responsive: true
  }

  graph_data = $("."+scope)
  chart = null
  if (pie)
    data = ( {value: $(cell).text().to_i(), color: purple(i,1.0), highlight: green(0,1.0), label: $(cell).data("label") } for cell, i in $(".cell", graph_data))
    options["legendTemplate"] = "<ul style=\"list-style-type: none;\" class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<segments.length; i++){%><li><span style=\"background-color:<%=segments[i].fillColor%>\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;&nbsp;<%if(segments[i].label){%><%=segments[i].label%> (<%=segments[i].value%>)<%}%></li><%}%></ul>"
    chart = new Chart(ctx).Pie(data,options)
  else
    series = ($(serie).data("label")||$(serie).text() for serie in $(".serie", graph_data))
    grid = (($(cell).text().to_i() for cell in $(".cell", row)) for row in $(".row", graph_data))
    series_data = grid[0].map (col, i) -> grid.map (row) -> row[i]
    datasets = ( {
        label: serie,
        fillColor: all(i,0.2),
        strokeColor: all(i,1.0),
        pointColor: all(i,1.0),
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: all(i,1.0),
        data: series_data[i]
      } for serie, i in series)
    data = { labels: $(label).text().trim() for label in $(".label", graph_data), datasets: datasets }

    options["legendTemplate"] = "<ul style=\"list-style-type: none;\" class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].strokeColor%>\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;&nbsp;<%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>"
    chart = new Chart(ctx).Line(data,options)
  
  $el.after(chart.generateLegend())
  
$ ->
  $(".graph").each ->
    draw_chart $(this)