jQuery(function($) {
    $('#close_cookie').on('click', function(evt) {
        evt.preventDefault();
        document.cookie="cookiepolicy=hide; expires=Thu, 18 Dec 2033 12:00:00 GMT";
        $(this).parent().hide();
    })
});
