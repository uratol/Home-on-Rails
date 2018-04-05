$(document).on('turbolinks:load', function() {
	
	function setSliderText(slider, value){
		slider.parent().find('._value').text(value);
	}
	
	var changing = false;
	
	$('._slider').each(function() {
		var slider = $(this);
		var container = slider.closest('.entity');
		slider.slider({
			range : false,
			min : slider.data('min'),
			max : slider.data('max'),
			step : slider.data('step'),
            value : slider.data('value'),
			orientation : slider.data('orientation'),
			slide : function(event, ui) {
				setSliderText($(this), ui.value);
			},
			start : function(event, ui) {
				changing = true;
			},
			stop : function(event, ui) {
			},
			change : function(event, ui) {
				if (isDesignMode)
					return;

				container = $(ui.handle).closest('div.slider');
                var ent_id = container[0].id;

				$.ajax({
					url : action_path('change'),
					method: 'POST',
					data : {
						root : $(".layout_container").attr('id'),
						id : ent_id,
						value : ui.value
					},
					success : function(data) {
						refreshEntityes(data);
						changing = false;
					},
					error : function(request, ajaxOptions, thrownError) {
						changing = false;
						onAjaxError(request, ajaxOptions, thrownError);
					}
				});
			}
		});
		container.on('entity:refresh', {
			slider : slider
		}, function(event, entity) {
			slider = event.data.slider;
			if (slider.find('.ui-state-active').length || changing) return;
			
			change = slider.slider("option", "change");
			slider.slider("option", "change", null);
			slider.slider("option", "value", entity.text);
			slider.slider("option", "change", change);
			setSliderText(slider, entity.text);
		});
	});
	
});
