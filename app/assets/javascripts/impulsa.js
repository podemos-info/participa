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
	// Ocultamos los temas que no tengan proyectos
	$('#botonera a').each(function() {
		var clase = $(this).attr('class');
		if (($("#proyectos .proyecto .temas a."+clase).length == 0) && (clase != "vertodos")) $(this).hide();
	});

	imagesLoaded($proyectos, function(){
		$proyectos.isotope({
			itemSelector: '.proyecto', 
			masonry: { gutter: 30 }
		});
		$("#proyectos .proyecto .temas a, #botonera a").on('click', function(e) {
			e.preventDefault();
			$("#botonera a").removeClass("active");
			var filter="."+$(this).attr('class');
			$proyectos.isotope({filter: filter});
			$("#botonera a"+filter).addClass("active");
		});
		$(".vertodos").on('click', function(e) {
			e.preventDefault();
			$proyectos.isotope({filter:""});
			$("#botonera a").removeClass("active");
		});
	});
})(jQuery);

