$(document).on('page:change', function() {

	/* prepend menu icon */
	$('.nav-wrap').prepend('<div class="menu-icon">Menu</div>');
	
	/* toggle nav */
	$(".menu-icon").on("click", function(){
		$(".nav").slideToggle();
		$(this).toggleClass("active");
	});

});
