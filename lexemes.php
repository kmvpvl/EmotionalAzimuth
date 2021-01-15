<?php

?>
<script>
function drawLexeme(lex) {
    s = "<lexeme>";
    s += "<normal>" + lex.lexeme + "</normal>";
    s += "<ignore>" + (lex.ignore?lex.ignore:"") + "</ignore>";
    s += "<emotion>" + (lex.emotion?lex.emotion:"") + "</emotion>";
    s += "</lexeme>";
    return s;
}
function drawLexemes() {
	//showLoading();
	var p = $.post("apiGetDictionary.php",
	{
		count: 10
	},
	function(data, status){
		//hideLoading();
		switch (status) {
			case "success":
                //debugger;
			    ls = JSON.parse(data);
                if ('OK' == ls.result) {
                    ls.data.forEach(function (item, index) {
                        $("instance").append(drawLexeme(item));
                    });
                }
				break;
			default:
				//clearInstance();
				//showLoginForm();
		}
	});
	p.fail(function(data, status) {
		hideLoading();
		switch (data.status) {
			case 400:
				//clearInstance();
				//showLoginForm();
				//showLoadingError(data.status + ": " + data.statusText + ". " + data.responseText);
				break;
			default:				
				//showLoadingError(data.status + ": " + data.statusText + ". " + data.responseText);
		}
	})
    
}

$(document).ready (function () {
    drawLexemes();
})
</script>