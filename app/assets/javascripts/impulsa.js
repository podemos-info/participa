;(function($) {
	var proyectos = $('#proyectos .proyecto');
	var num_proyectos = proyectos.length;	
	var $proyectos = $('#proyectos');
	/*$proyectos.isotope({
		itemSelector: '.proyecto', 
		masonry: { gutter: 40 },
		getSortData: {
        	votos: function(item){
            	return parseFloat($(item).attr("data-index"));
        	}
		},
		sortBy: 'votos'
	});*/

	$("#proyectos .proyecto .temas a, #botonera a").on('click', function(e) {
		e.preventDefault();
		var filter="."+$(this).attr('class');
		$proyectos.isotope({filter: filter});
		$("#botonera a").removeClass("active");
		$("#botonera a"+filter).addClass("active");
	});
	$(".vertodos").on('click', function(e) {
		e.preventDefault();
		$proyectos.isotope({filter:""});
		$("#botonera a").removeClass("active");
	});
	imagesLoaded($("#proyectos"), function(){$proyectos.isotope()});
})(jQuery);

