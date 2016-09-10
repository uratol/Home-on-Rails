var isDesignMode = false;

$(document).on('turbolinks:load', function() {
	var startMenuCache = [];
	var draggableEntities = $('.entity');
	var sortableEntities = $('.nav');

	function startDesign() {
		$('#design_form [type=submit],[type=reset]').removeAttr('disabled');
	}


	function designMode(val) {
		if ( typeof (val) === 'undefined') {
			val = !isDesignMode;
		};

		isDesignMode = val;

		if (isDesignMode) {
			$('#design_container').show();
			draggableEntities.draggable({
				start : function(event, ui) {
					if (!$(this).data('startPosition')) {
						$(this).data('startPosition', $(this).position());
					};
				},
				stop : function(event, ui) {
					startDesign();
					arrangeLayout();
				},
				cancel: false,
				distance: 10
			});

			sortableEntities.sortable({
				items : 'li.menu_entity',
				start : function(event, ui) {
					if (startMenuCache.length == 0) {
						sortableEntities.find('li.menu_entity').each(function(index, anchor) {
							startMenuCache.push(anchor.innerHTML);
						});
					}
				},
				stop : function(event, ui) {
					startDesign();
				}
			});

			$('.design_menu_item').addClass('checked');
			
			createContextMenu(".entity");
		} else {
			if (startMenuCache.length > 0) {
				location.reload();
				return;
			};	

			$('*:data(startPosition)').each(function() {
				Startpos = $(this).data("startPosition");
				$(this).css({
					left : Startpos.left,
					top : Startpos.top
				}).removeData('startPosition');
			});

			sortableEntities.sortable('destroy');

			if (startMenuCache.length > 0) {
				sortableEntities.find('li.menu_entity').each(function(index, anchor) {
					anchor.innerHTML = startMenuCache[index];
				});
			};

			$('#design_container').hide();

			draggableEntities.draggable('destroy');
			$('.design_menu_item').removeClass('checked');
			$('#design_form [type=submit]').attr('disabled','disabled');
			destroyContextMenu(".entity");
			arrangeLayout();
		};

	};

	$('#design_container').hide();

	$('.design_menu_item').click(function() {
		designMode();
	});

	$('#design_form').on('reset', function() {
		designMode(false);
	});

	$('#design_form').submit(function(e) {

		data_array = $('*:data(startPosition)').map(function() {
			return {
				id : this.id,
				left : $(this).position().left,
				top : $(this).position().top
			};
		}).toArray();

		// e.preventDefault();

		if (startMenuCache.length > 0) {
			data_array = data_array.concat($('li.menu_entity', sortableEntities).map(function() {
				return {
					id : $('a',this).attr('id'),
					index : $(this).index()
				};
			}).toArray());
		};
		$('#data', this).val(JSON.stringify(data_array));
	});
});
