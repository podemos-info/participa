jQuery(function($) {
    var $entity  = $('#collaboration_ccc_entity');
    var $office  = $('#collaboration_ccc_office');
    var $dc      = $('#collaboration_ccc_dc');
    var $account = $('#collaboration_ccc_account');

    var onlyNumbersWithMaxLength = function(maxLength, $nextField) {
        return function(evt) {
            var val = $(this).val();
            val = val.replace(/[^0-9]/g, ""); // Remove anything but numbers
            $(this).val(val);

            if (val.length >= maxLength) {
                if ($nextField) {
                    $nextField.focus();
                } else {
                    $(this).blur();
                }
            }
        };
    };

    $entity.on('keyup', onlyNumbersWithMaxLength(4, $office));
    $office.on('keyup', onlyNumbersWithMaxLength(4, $dc));
    $dc.on('keyup', onlyNumbersWithMaxLength(2, $account));
    $account.on('keyup', onlyNumbersWithMaxLength(10));
});
