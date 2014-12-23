
function show_provinces(country_code){
  // change to provinces for a given country
  var select_wrapper = $('#js-registration-user_province-wrapper');
  var url = "/registrations/regions/provinces?no_profile=1&user_country=" + country_code;

  $('#user_town').disable_control();
  $('#user_province').disable_control();
  select_wrapper.load(url, function() {
    var prov_select = $('select#user_province');
    if (prov_select.length>0 && prov_select.select2)
      prov_select.select2({
        formatNoMatches: "No se encontraron resultados"
      });
    else
      show_towns(null);
  });
}

var no_towns_html="";
function show_towns(parent, field, country_code, province_code, prefix){
  // change to provinces for a given country
  var select_wrapper = $('#js-registration-'+field+'-wrapper');

  $('#'+field).disable_control();
  if (province_code && country_code == "ES") {
    var url = "/registrations/"+prefix+"/municipies?no_profile=1&user_country=ES&"+parent+"=" + province_code;
    var has_towns = true;
  } else {
    var url = "/registrations/"+prefix+"/municipies?no_profile=1";
    var has_towns = false;
  }

  if (!has_towns && no_towns_html) {
    select_wrapper.html(no_towns_html);
  } else {
    select_wrapper.load(url, function(response) {
      if (has_towns) {
        var town_select = $('select#'+field);
        if (town_select.select2)
          town_select.select2({
            formatNoMatches: "No se encontraron resultados"
          });


          if (field=="user_town") {
            var options = town_select.children("option");
            if (options.length>1) {
              var postal_code = $('#user_postal_code').val();
              var prefix = options[1].value.substr(2,2);
              if (postal_code.length<5 || postal_code.substr(0, 2) != prefix) {
                $('#user_postal_code').val(prefix);
              }
            }
          }
      } else
        no_towns_html = response;
    });
  }
}

function toggle_vote_town(country){
    $("#foreign_vote_town").toggle(country != "ES");
}
$(function() {

  var country_selector = $('select#user_country');
  if (country_selector.length) {
    $.fn.disable_control = function( ) {
      if (this.data("select2"))
        this.select2("enable", false).select2("val", "").attr("data-placeholder", "-").select2();
      else
        this.prop("disabled", true).val("").attr("placeholder", "-");
      return this;
    };

    country_selector.on("change", function() {
      var country = $(this).val();
      toggle_vote_town(country);
      show_provinces( country );
    });

    $(document.body).on("change", 'select#user_province', function() {
      show_towns( "user_province", "user_town", country_selector.val(), $(this).val(), "regions" );
    });

    $('select#user_vote_province').on("change", function() {
      show_towns( "user_vote_province", "user_vote_town", "ES", $(this).val(), "vote" );
    });

    toggle_vote_town(country_selector.val());
    if ($("select#user_province").is(":disabled")) {
      country_selector.trigger("change");
    }
    if ($("select#user_vote_town").is(":visible")) {
      $('select#user_vote_province').trigger("change");
    }
  }
});

