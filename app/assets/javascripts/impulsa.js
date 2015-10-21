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
		if ($("#proyectos .proyecto").hasClass(clase)) $(this).show();//$(this).attr('display', 'inline-block').show();
		//if (!($("#proyectos .proyecto").hasClass(clase)) && (clase != "vertodos")) $(this).hide();
		/*if (($("#proyectos .proyecto .temas a."+clase).length == 0) && (clase != "vertodos")) $(this).hide();*/
	});

	imagesLoaded($proyectos, function(){
		$proyectos.isotope({
			itemSelector: '.proyecto', 
			masonry: { gutter: 30 },
			getSortData: {
				estado: function(proyecto) {
					var orden = 0;
					if ($(proyecto).hasClass("validated")) orden=1;
					if ($(proyecto).hasClass("winner")) orden=2;
					return orden;
				},
		    	votos: function(item){
		        	return parseInt($(item).attr("data-votes"));
		    	}
			},
			sortBy: ['estado', 'votos']
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
		$('#cargando').fadeOut('slow', function() { $('#proyectos').fadeIn(); });
	});
})(jQuery);

