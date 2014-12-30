jQuery(function($) {
    $('.box').on('click', '.box-close', function(evt){
        evt.preventDefault();
        $(this).closest(".box").hide("fast");
    });
})
