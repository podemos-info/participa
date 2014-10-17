jQuery(function($) {
    $('.box').on('click', '.box-close', function(evt){
        evt.preventDefault();
        var box = $(this).parent().parent();
        var divCol = box.parent();
        var flashRoot = divCol.parent().parent();

        if(divCol.children().length === 1) {
            flashRoot.hide("fast")
        } else {
            box.hide("fast");
        }
    });
})
