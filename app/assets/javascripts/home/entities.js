function setupEditor(){
    var editor = document.getElementById('editor');
    if (!editor)
        return;
    editor = ace.edit(editor);
    editor.getSession().setMode("ace/mode/ruby");
    editor.setOptions({
        maxLines: 80, minLines: 15, tabSize: 2, useSoftTabs: true
    });
    editor.$blockScrolling = Infinity;

    // editor.session.setNewLineMode("unixs")

    editor.commands.addCommand({
        name: "submit",
        exec: function () {
            $('#new_entity,#edit_entity').submit();
        },
        bindKey: "Ctrl-S"
    });

    $('#new_entity,#edit_entity').submit(function (e) {
        $('#entity_behavior_script').val(editor.getValue());
    });

    $('.method').click(function (e) {
        var pos = editor.getCursorPosition();
        var pattern = $(this).data('pattern') + '\n\n';
        editor.insert(pattern);
        editor.gotoLine(pos.row + 2);
        editor.insert('  ');
//					editor.getSession().getSelection().selectionLead.setPosition(pos);
        editor.focus();
    });
}

$(document).on('turbolinks:load', function() {
    createContextMenu('table.entities tr.entity');
    setupEditor();
});