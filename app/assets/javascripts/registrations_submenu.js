jQuery(function() {
    var $content = $('#personal-data-content');
    var $submenu = $('#personal-data-submenu');

    if ($submenu.length) {
        var hideContent = function() {
            $content.find('.js-personal-content').hide();
        };

        var removeActive = function() {
            $submenu.find('li.active').removeClass('active');
        };

        var showTab = function(submenu) {
            hideContent();
            removeActive();
            var tab = $("a[href="+submenu+"]", $submenu);
            tab.parent().addClass('active');
            $(submenu).show();
        };

        $submenu.on('click', 'a', function(evt) {
            evt.preventDefault();
            var target = $(this).attr('href');
            window.location.hash = target;
            showTab(target);
        });

        $content.on('click', 'a', function(evt) {
            evt.preventDefault();
            var target = $(this).attr('href');
            window.location.hash = target;
            showTab(target);
        });

        if (window.location.hash) {
            showTab(window.location.hash);
            $("#errors_in_form").prependTo(window.location.hash);
            $(".js-personal-content:not("+window.location.hash+") .alert-nexttolabel", $content).remove();
        }
    }
});
