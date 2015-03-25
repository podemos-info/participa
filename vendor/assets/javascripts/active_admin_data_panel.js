$(function() {
  $(".panel[data-panel]").each(function() {
    var $this = $(this);
    var myid = $this.data("panel-id");
    var myparent = $this.data("panel-parent");
    var anchor = myparent ? myparent+"-"+myid : myid;

    var $a = $("<a id='"+anchor+"' href='#"+anchor+"'>").on("click", function(event) {
      $(this).closest(".panel").find(".panel_contents:first").each(function() {
        $(this).slideToggle();
      });
      $(this).closest("h3").each(function() {
        $(this).toggleClass("panel-collapsed");
      });
      event.preventDefault();
    })
    var $h3 = $this.find("h3:first");
    $h3.each(function() {
      $(this).wrapInner($a).prepend("<a name='"+anchor+"'>")
    });
    if ($this.data("panel") == 'collapsed' && window.location.hash.indexOf(myid+"-")!=1 && window.location.hash!="#"+anchor) {
      $h3.each(function() {
        $(this).addClass('panel-collapsed')
      });
      $this.find(".panel_contents:first").each(function() {
        $(this).hide()
      });
    }
  });

  $(".panel[data-panel] tr").on("click",function(){$(this).toggleClass("full")});
});
