window.addEventListener('message', function(e) {
	if (e.data=="top") scroll(0,0);
});

$(function() {
  // Fixes Firefox bug: https://bugzilla.mozilla.org/show_bug.cgi?id=279048
  $("iframe").each(function(i,iframe) {
    iframe.contentWindow.location.href = iframe.src;
  });

  var lang_re = /https?\:\/\/.*\/(..)\/.*/i;
  var lang = lang_re.exec(window.location);
  if (lang) lang = lang[1]; 
  window.lang = (["es","ca"].indexOf(lang)==-1) ? "es" : lang;
})
