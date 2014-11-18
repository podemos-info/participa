
function show_provinces(country_code){
  // change to provinces for a given country
  var select_wrapper = $('#js-registration-subregion-wrapper');
  var url = "/registrations/regions/provinces?no_profile=1&user_country=" + country_code;

  $('#user_town').disable_control();
  $('#user_province').disable_control();
  select_wrapper.load(url, function() {
    var prov_select = $('select#user_province');
    if (prov_select.length>0)
      prov_select.select2({
        formatNoMatches: "No se encontraron resultados"
      });
    else
      show_towns(null);
  });
}

var no_towns_html="";
function show_towns(province_code){
  // change to provinces for a given country
  var select_wrapper = $('#js-registration-municipies-wrapper');

  $('#user_town').disable_control();
  if (province_code && $("select#user_country").val() == "ES") {
    var url = "/registrations/regions/municipies?no_profile=1&user_country=ES&user_province=" + province_code;
    var has_towns = true;
  } else {
    var url = "/registrations/regions/municipies?no_profile=1";
    var has_towns = false;
  }


  if (!has_towns && no_towns_html) {
    select_wrapper.html(no_towns_html);
  } else {
    select_wrapper.load(url, function(response) {
      if (has_towns)
        $('select#user_town').select2({
          formatNoMatches: "No se encontraron resultados"
        });
      else
        no_towns_html = response;
    }).show();
  }
}

$(function() {

  $.fn.disable_control = function( ) {
    if (this.data("select2"))
      this.select2("enable", false).select2("val", "").attr("data-placeholder", "-").select2();
    else
      this.prop("disabled", true).val("").attr("placeholder", "-");
    return this;
  };

  $('select#user_country').on("change", function() {
    show_provinces( $(this).val() );
  });

  $(document.body).on("change", 'select#user_province', function() {
    show_towns( $(this).val() );
  });

  if ($("select#user_province").is(":disabled")) {
    $('select#user_country').trigger("change");
  }
});
