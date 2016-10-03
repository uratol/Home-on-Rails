$(document).on('turbolinks:load', function() {
	
	function setSliderText(slider, value){
		slider.parent().find('._value').text(value);
	}
	
	var changing = false;
	
	$('._slider').each(function() {
		slider = $(this);
		container = slider.closest('.entity');
		slider.slider({
			range : false,
			min : slider.data('min'),
			max : slider.data('max'),
			step : slider.data('step'),
			orientation : slider.data('orientation'),
			slide : function(event, ui) {
				setSliderText(slider, ui.value);
			},
			start : function(event, ui) {
				changing = true;
			},
			stop : function(event, ui) {
			},
			change : function(event, ui) {
				if (isDesignMode)
					return;

				var ent_id;
				container = $(ui.handle).closest('div.slider');
				ent_id = container.data('twin');
				if (!ent_id)
					ent_id = container[0].id;

				$.ajax({
					url : '/main/change',
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
					error : function(data) {
						changing = false;
						onAjaxError;
					}
				});
			},
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
