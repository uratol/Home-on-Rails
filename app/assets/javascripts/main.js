function message(msg){
	$('#flash_messages').text(msg);
}

var onAjaxError = function (request, ajaxOptions, thrownError) {
			if (thrownError)
	        	message(thrownError+': '+request.responseText.substring(0,550));
	     };

function setBrightness(elem, brightness) {
	f = 'brightness(' + brightness + '%)';
	elem.css('-webkit-filter', f);
	elem.css('filter', f);
};

function refreshEntityes(entities) {
	entities.forEach(function(entity) {
		elem = $('#img' + entity.id);
		if (elem.attr("src") != entity.img) {
			elem.attr("src", entity.img);
		};
		setBrightness(elem, entity.brightness);
	});
	
};

function refreshRequest() {
	if (!$('.layout_container').length)
		return;
		
	$.ajax({
		 url: "/main/refresh?root=" + $(".layout_container").attr('id')
		,success: function(data) {
			refreshEntityes(data);
			}
		,error: onAjaxError
	});

};

function arrangeLayout() {
	//lc.height(lc[0].scrollHeight);

	var maxRight = 0, maxBottom = 0, tmpInt;
	
	function calcChildrenBounds(e){
		e.children(':not(script)').each(function(){
			tmpInt = $(this).offset().top + $(this).outerHeight(true);
			if (tmpInt > maxBottom) { 
				maxBottom = tmpInt;
			};
	
			tmpInt = $(this).offset().left + $(this).outerWidth(true);
			if (tmpInt > maxRight) { 
				maxRight = tmpInt;
			};
			
			if (!$(this).hasClass('chart_div') ) {
				calcChildrenBounds($(this));
			};
		});
		
	};
	
	$(".layout_container").each(function(){
		calcChildrenBounds($(this));
	});

	$('.layout_container').width(maxRight - $('.layout_container').offset().left);
	$('.layout_container').height(maxBottom - $('.layout_container').offset().top);
};

$(document).on('page:change', function() {
	
	$(".at_click").hover(function(){
		
		if ($(this).data('twin'))
			$els = $(".at_click[data-twin="+$(this).data('twin')+"]");
		else	
			$els = $(this);
		  
		$els.toggleClass('hover');
	});
	
	$(".at_click").click(function(){
		if(isDesignMode) return;
		
		var ent_id;
		ent_id = $(this).data('twin');
		if (!ent_id)
			ent_id = this.id;  
		
		$.ajax({
			 url: '/main/click'
			,data: {root: $(".layout_container").attr('id'), id: ent_id}
			,success: function(data) {
				refreshEntityes(data);
				}
			,error: onAjaxError
		});
	});
	

	refreshRequest();

	if ($('.layout_container').length) {
		// setup height container by content
		// browser needs timeout for building elements
		setTimeout(function() {
		arrangeLayout();
		}, 500);
	};
});

setInterval(function() {
	refreshRequest();
}, 5000);

