var isRecognizing = false;

function dialogRow(s, cl) {
	jQuery('<div/>', {
		class : cl,
		text : s
	}).appendTo(dialog);
	dialog.scrollTop = dialog.scrollHeight;
};

$(document).on('page:change',function() {
	$("#mic").click(function() {
		isRecognizing = true;
		startRecognizing(function(text) {
			isRecognizing = false;
			$("#commandText").val(text);
			$("#commandForm").submit();
		});
	});

	$("#commandForm").submit(function() {
		dialogRow($("#commandText").val(), 'command');
	});

	$("#commandForm").on("ajax:success", function(e, data, status, xhr) {
		dialogRow(data.response, 'response');
		$("#commandText").val('');
	}).on("ajax:error", function(e, xhr, status, error) {
		dialogRow(error, 'error');
		$("#commandText").val('');
	});

	$('#commandSubmitButton').click(function() {
		commandText.focus();
	});

	$('#commandText').focus();

});
