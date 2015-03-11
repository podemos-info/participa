$(function() {
  $(".panel[data-panel]").each(function() {
    var $this = $(this);
    var $a = $("<a href='javascript:void(null)'>").on("click", function(event) {
      $(this).closest(".panel").find(".panel_contents").each(function() {
        $(this).slideToggle();
      });
      $(this).closest("h3").each(function() {
        $(this).toggleClass("panel-collapsed");
      });
    })
    var $h3 = $this.find("h3:first");
    $h3.each(function() {
      $(this).wrapInner($a)
    });
    if ($this.data("panel") == 'collapsed') {
      $h3.each(function() {
        $(this).addClass('panel-collapsed')
      });
      $this.find(".panel_contents").each(function() {
        $(this).hide()
      });
    }
  });
});
