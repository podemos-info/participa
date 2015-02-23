window.addEventListener('message', function(e) {
	if (e.data=="top") scroll(0,0);
});

$(function() {
  // Fixes Firefox bug: https://bugzilla.mozilla.org/show_bug.cgi?id=279048
  $("iframe").each(function(i,iframe) {
    iframe.contentWindow.location.href = iframe.src;
  });
})
