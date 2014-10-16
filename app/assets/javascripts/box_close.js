jQuery(function($) {
    $('.box').on('click', '.box-close', function(evt){
        evt.preventDefault();
        $(this).parent().parent().hide("fast");
    });
})
