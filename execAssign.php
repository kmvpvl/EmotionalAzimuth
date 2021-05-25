<exec-assign>
    <exec-toolbar-control>
    </exec-toolbar-control>
    <lexemes>
    </lexemes>
</exec-assign>
<script>
var assignment = null;
var current_lexeme_id = null;
function saveEmotion(){
    var e = new Object();
    for (const[i, v] of Object.entries(emotions)){
        e[v] = $('[modal_emotion="'+v+'"]').val();
    }
    var d = Object();
    d.assign_id = assignment.id;
    d.lexeme_id = current_lexeme_id;
    Object.assign(d, e);
    Object.assign(assignment.assessments[current_lexeme_id], e);
    sendDataToServer('apiSaveAssessment', d, function(data, status){
        var ls = recieveDataFromServer(data, status);
        if (ls && ls.result=='OK') {
            drawFlower($('lexeme[lexeme_id="'+ls.data.lexeme_id+'"] > flower'), ls.data);
            
        } else {
            debugger;
            showError('Could not save assessment!');
        }
    });
}
function loadEmotion(lexeme_id){
    //debugger;
    current_lexeme_id = lexeme_id;
    $('#dlgLexemeModalLongTitle').text(assignment.assessments[current_lexeme_id].lexeme);
    for (const[i, v] of Object.entries(emotions)){
        if (assignment.assessments[current_lexeme_id][v])
            $('[modal_emotion="'+v+'"]').val(assignment.assessments[current_lexeme_id][v]);
        else
        $('[modal_emotion="'+v+'"]').val(0);
    }
    drawFlower($('.modal-body > flower'), assignment.assessments[current_lexeme_id]);
}
$('#btn-save-prev').off('click');
$('#btn-save-next').off('click');
$('#btn-save-next').click(function(){
    saveEmotion();
    var t = Object.keys(assignment.assessments).indexOf(current_lexeme_id);
    if (t < Object.keys(assignment.assessments).length - 1) {
        loadEmotion(Object.keys(assignment.assessments)[t+1]);
    } else {
        $('#dlgLexemeModal').modal('hide');
    }
});

$('#btn-save-prev').click(function(){
    saveEmotion();
    var t = Object.keys(assignment.assessments).indexOf(current_lexeme_id);
    if (t > 0) {
        loadEmotion(Object.keys(assignment.assessments)[t-1]);
    } else {
        $('#dlgLexemeModal').modal('hide');
    }
});

sendDataToServer('apiGetAssign', {id: <?=$_POST["data"]["id"]?>}, function(data, status){
    var ls = recieveDataFromServer(data, status);
    if (ls && ls.result=='OK') {
        assignment = new EAAssign(ls.data, $('exec-toolbar-control'));
        assignment.draw();
        assignment.drawAssessments($('lexemes'));
        $('lexeme').click(function(){
            loadEmotion($(this).attr('lexeme_id'));
            $('#dlgLexemeModal').modal('show');
            //drawFlower($('.modal-body > flower'), {joy:1, trust:0.8});
        });
    } else {
        showError("Object EAAssign damaged");
    }
});
</script>
