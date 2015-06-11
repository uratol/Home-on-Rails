function createContextMenu(selector) {
	$.contextMenu({
		// define which elements trigger this menu
		selector : selector,
		build: function($trigger, e){
			return {
				zIndex: 999
				 ,items : {
							title: {name: $trigger.attr("name"), disabled: true
							}
							,edit : {
								 name : "Edit..."
								,callback : function(key, opt) {
									document.location = "entities/"+$trigger.attr("id")+"/edit";
								}
							}
							,insert : {
								 name : "Insert..."
								,callback : function(key, opt) {
									document.location = "entities/insert/"+$trigger.attr("id");
								}
							}
							,copy : {
								 name : "Copy..."
								,callback : function(key, opt) {
									document.location = "entities/new."+$trigger.attr("id");
								}
							}
							,delete : {
								 name : "Delete"
								,callback : function(key, opt) {
									if (confirm("Are you sure?"))
										document.location = "entities/"+$trigger.attr("id")+"/destroy";
								}
							}
					}
			};	
		}	

		// there's more, have a look at the demos and docs...
	});
};	

function destroyContextMenu(selector) {
	$.contextMenu( 'destroy', selector );
};	
