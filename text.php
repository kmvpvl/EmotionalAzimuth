<textarea id="emText" class="emotional-text">
</textarea>
<button id="btnAnalyzeText">Go</button>
<result>
</result>
<script>
function drawText(t) {
    res = "<emotional_text>"+drawFlower(t.emotion, 200)+"<flower></flower>";
    res += "<emotional_text_preview>" + t.text.substr(0, 50) + "..." + "</emotional_text_preview>";
    if (t.sentences) {
        res += "<sentences>";
        t.sentences.forEach(function (value, index){
            res += drawText(value);
        });
        res += "</sentences>";
    }
    if (t.lexemes) {
        res += "<lexemes>";
        t.lexemes.forEach(function (value, index){
            res += drawLexeme(value);
        });
        res += "</lexemes>";
    }
    res += "</emotional_text>";
    return res;
}

$("#btnAnalyzeText").on ('click', function () {
	showLoading();
	var p = $.post("apiGetTextEmotion.php", {
		username: $("#username").val(),
		password: $("#password").val(),
		language: $("#language").val(),
        timezone: $("#timezone").val(),
        text: $("#emText").val()
    },
	function(data, status){
		hideLoading();
		switch (status) {
			case "success":
                ls = JSON.parse(data);
                //debugger;
                if ('OK'== ls.result) {
                    $("result").html(drawText(ls.data));
                }
				break;
			default:
				clearLexemesList();
				showLoginForm();
		}
	});
	p.fail(function(data, status) {
		hideLoading();
		switch (data.status) {
			case 401:
				showLoginForm();
				break;
			default:;			
		}
		showLoadingError(data.status + ": " + data.statusText + ". " + data.responseText);
    });
});
</script>