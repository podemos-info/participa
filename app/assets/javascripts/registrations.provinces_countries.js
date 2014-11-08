//var init_registrations_subregions, province_change, subregion_change;
//
//function country_change() {
//  var country_code, select_wrapper, url;
//  var $country_select = $('.js-registration-country');
//  select_wrapper = $('#js-registration-subregion-wrapper');
//  //$('select', select_wrapper).attr('disabled', true);
//  country_code = $country_select.val();
//  url = "/registrations/regions/provinces?parent_region=" + country_code;
//  select_wrapper.load(url, function() {
//    var province;
//    if ($('.js-registration-province').length > 1) {
//      province = $('.js-registration-province').html();
//      $('#user_province').val(province);
//    }
//    $('#user_province').select2({
//      formatNoMatches: "No se encontraron resultados"
//    });
//    province_change();
//    $('#user_province').on("change", function() {
//      province_change();
//    });
//  });
//};
//
//function province_change() {
//  var province_code, select_wrapper, url;
//  if ($('#user_country').val() === "ES") {
//    select_wrapper = $('#js-registration-municipies-wrapper');
//    //$('select', select_wrapper).attr('disabled', true);
//    province_code = $('#user_province').val();
//console.log(province_code);
//    if (province_code) {
//      url = "/registrations/regions/municipies?parent_region=" + province_code;
//      select_wrapper.load(url, function() {
//        $('#town').select2({
//          formatNoMatches: "No se encontraron resultados"
//        });
//      });
//    }
//  }
//};
//
//init_registrations_subregions = function() {
//  if ($('.js-registration-country').val() === "") {
//    $('select.js-registration-country').val('ES').trigger('change');
//  }
//
//  if ($("#user_province").val() == "") {
//    country_change();
//  }
//  $('.js-registration-country').on("change", function() {
//    country_change();
//  });
//
//  province_change();
//  $('#user_province').on("change", function() {
//    province_change();
//  });
//};
//
//$(window).bind('page:change', function() {
//  init_registrations_subregions();
//});
//
//$(function() {
//  init_registrations_subregions();
//});
//


function show_provinces(country_code){
  // change to provinces for a given country
  select_wrapper = $('#js-registration-subregion-wrapper');
  url = "/registrations/regions/provinces?parent_region=" + country_code;
  select_wrapper.load(url, function() {
    var province = $("#user_province option:selected").val()
    $('#user_province').val(province).trigger('change');
    console.log(province);
    show_municipalities(province);
    $('#user_province').select2({
      formatNoMatches: "No se encontraron resultados"
    });
  });
}

function show_municipalities(province_code){
  // change to provinces for a given country
  select_wrapper = $('#js-registration-municipies-wrapper');
  url = "/registrations/regions/municipies?parent_region=" + province_code;
  select_wrapper.load(url, function() {
    $('#town').select2({
      formatNoMatches: "No se encontraron resultados"
    });
  });
}


$(function() {
  show_provinces( $('#user_country').val() );

  $('#user_country').on("change", function() {
    show_provinces( $(this).val() );
  });

  $('#user_province').on("change", function() {
    if ( $("#user_country") == "ES" ) {
      show_municipalities( $(this).val() );
    }
  });

});
