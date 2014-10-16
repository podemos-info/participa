jQuery(function() {
    var $content = $('#personal-data-content');
    var $submenu = $('#personal-data-submenu');

    var hideContent = function() {
        $content.find('.js-personal-content').hide();
    };

    var removeActive = function() {
        $submenu.find('li.active').removeClass('active');
    };

    $submenu.on('click', 'a', function(evt) {
        evt.preventDefault();
        hideContent();
        removeActive();
        $(this).parent().addClass('active');
        var target = $(this).attr('href');
        $(target).show();
    });
});
