<input id="filterIgnore" type="checkbox" checked data-toggle="toggle" data-on="evaluated" data-off="not eval" data-onstyle="success" data-offstyle="danger" data-width="100">
<input id="searchString" type="string" placeholder="Lexeme search..."/>
<input id="searchTOC" style="display:none;"/>
<lexemes_list></lexemes_list>
<seek></seek>
<script>
$("#filterIgnore").bootstrapToggle();
$("#dlgModalEditLexemeEmotionIgnoreOnOff").bootstrapToggle();
$("#dlgModalEditLexemeEmotionIgnoreStopword").bootstrapToggle();
$("#filterIgnore").on('change', function(){
	$("#searchTOC").val("");
	drawLexemes();
});
$("#searchString").on('input', function(){
	$("#searchTOC").val("");
	drawLexemes();
});
$("#searchTOC").on('input', function(){
	$("#searchString").val("");
	drawLexemes();
});
$(window).resize(function () {
	resizeLexemes()
});

function resizeLexemes() {
	$("lexemes_list").outerWidth($("seek").position().left - $("lexemes_list").position().left);
	$("lexemes_list").outerHeight($("instance").innerHeight() - $("lexemes_list").position().top);
	//debugger;
	$("seek").outerHeight($("instance").innerHeight() - $("seek").position().top);
}

function clearLexemesList(){
	$('lexemes_list').html("");
}
var lexeme = new Object();
function saveLexeme(lex) {
	showLoading();
	var p = $.post("apiAssignDraftEmotionToLexeme.php", {
		username: $("#username").val(),
		password: $("#password").val(),
		language: $("#language").val(),
		timezone: $("#timezone").val(),
		lexeme: lex },
	function(data, status){
		hideLoading();
		switch (status) {
			case "success":
                drawLexemes();
				break;
			default:
				clearLexemesList();
				showLoginForm();
		}
	});
	p.fail(function(data, status) {
		hideLoading();
		switch (data.status) {
			case 400:
			case 401:
				showLoginForm();
				break;
			default:;			
		}
		showLoadingError(data.status + ": " + data.statusText + ". " + data.responseText);
	})
}
function drawLexemes() {
	showLoading();
	//debugger;
	var p = $.post("apiGetDictionary.php",
	{
		username: $("#username").val(),
		password: $("#password").val(),
		language: $("#language").val(),
		timezone: $("#timezone").val(),
		first_letters: $("#searchString").val(),
		toc: $("#searchTOC").val(),
		stopword: $("#filterIgnore").is(':checked')?1:0,
		count: 10
	},
	function(data, status){
		hideLoading();
		switch (status) {
			case "success":
                //debugger;
			    ls = JSON.parse(data);
                if ('OK' == ls.result) {
					clearLexemesList();
                    ls.data.lexemes.forEach(function (item, index) {
                        $("lexemes_list").append(drawLexeme(item));
					});
					resizeLexemes();
					$("seek").html(drawTOC(ls.data.toc, $("seek").innerHeight()));
					$("toc").removeClass('active');
					if ($("#searchTOC").val()) $("toc:contains('" + $("#searchTOC").val() + "')").addClass("active");
					$("toc").on('click', function () {
						$("#searchString").val("");
						$("#searchTOC").val($(this).text());
						$("lexemes_list").scrollTop(0);
						$("#searchTOC").trigger("input");
					});
					$("lexeme > stopword:contains('1')").parent().addClass('stopword');
					$('lexeme').on ('click', function(event) {
						lexeme.id = event.currentTarget.attributes['lexeme_id'].nodeValue;
						lexeme.lexeme = $('lexeme[lexeme_id='+lexeme.id+'] > normal').text();
						lexeme.lang = $('lexeme[lexeme_id='+lexeme.id+'] > lang').text();
						lexeme.stopword = $('lexeme[lexeme_id='+lexeme.id+'] > stopword').text();
						lexeme.emotion = JSON.parse($('lexeme[lexeme_id='+lexeme.id+'] > emotion').text());
						$('#dlgModalEditLexemeTitle').text(lexeme.lexeme);
						$('#dlgModalEditLexemeFlower').html(drawFlower(lexeme.emotion, 200));
						$('[modal_emotion]').val(0);
						emotions.forEach(function (item, index) {
                        	$("[modal_emotion='"+item+"']").val(lexeme.emotion[item]?lexeme.emotion[item]:0);
						});
						$('[modal_emotion]').on ('input', function(event) {
							axis = event.currentTarget.attributes['modal_emotion'].nodeValue;
							lexeme.emotion[axis] = $("[modal_emotion='"+axis+"']").val();
							$('#dlgModalEditLexemeFlower').html(drawFlower(lexeme.emotion, 200));
						});
						switch (lexeme.stopword) {
							case '':
								$('#dlgModalEditLexemeEmotionIgnoreOnOff').bootstrapToggle('on');
								$('#dlgModalEditLexemeEmotionIgnoreStopword').bootstrapToggle('enable');
								break;
						
							case '0':
								$('#dlgModalEditLexemeEmotionIgnoreOnOff').bootstrapToggle('on');
								$('#dlgModalEditLexemeEmotionIgnoreStopword').bootstrapToggle('enable');
								$('#dlgModalEditLexemeEmotionIgnoreStopword').bootstrapToggle('off');
								break;

							case '1':
								$('#dlgModalEditLexemeEmotionIgnoreOnOff').bootstrapToggle('on');
								$('#dlgModalEditLexemeEmotionIgnoreStopword').bootstrapToggle('enable');
								$('#dlgModalEditLexemeEmotionIgnoreStopword').bootstrapToggle('on');
								break;

							default:
								break;
						}
						$('#dlgModalEditLexemeEmotionIgnoreOnOff').change(function() {
							$('#dlgModalEditLexemeEmotionIgnoreStopword').bootstrapToggle($(this).prop('checked')?'enable':'disable'); 
							lexeme.stopword = $(this).prop('checked')?($('#dlgModalEditLexemeEmotionIgnoreStopword').prop('checked')?1:0):null;
						});
						$('#dlgModalEditLexemeEmotionIgnoreStopword').change(function() {
							lexeme.stopword = $('#dlgModalEditLexemeEmotionIgnoreOnOff').prop('checked')?($('#dlgModalEditLexemeEmotionIgnoreStopword').prop('checked')?1:0):null;
						});
						$("#dlgModalEditLexeme").modal('show');
					});
                } else {
					showLoadingError(ls.description);
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
				clearLexemesList();
				showLoginForm();
				showLoadingError(data.status + ": " + data.statusText + ". " + data.responseText);
				break;
			default:				
				showLoadingError(data.status + ": " + data.statusText + ". " + data.responseText);
		}
	})
    
}

$(document).ready (function () {
	drawLexemes();
	$('[dlg-button="btn-dlgModal-ok"]').on('click', function () {
		saveLexeme(lexeme);
		$("#dlgModalEditLexeme").modal('hide');
		drawLexemes();
	});
})

function drawEmotion (emotion) {
	s = '{';
	if (emotion) {
		for (i=0; i<N; i++) {
			if (i>0) s+=',';
			axis = emotion[emotions[i]];
			s += '"' + emotions[i] + '": '+axis;
		}
	}
	s += '}';
	return s;
}

</script>
<div class="modal fade" id="dlgModalEditLexeme" tabindex="-1" role="dialog" aria-labelledby="dlgModalLongTitle" aria-hidden="true">
	<div class="modal-dialog" role="document">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title" id="dlgModalEditLexemeTitle">Modal title</h5>
				<button type="button" class="close" data-dismiss="modal" aria-label="Close">
					<span aria-hidden="true">&times;</span>
				</button>
			</div>
			<div class="modal-body container">
<?php
include ('editFlower.php');
?>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
				<button type="button" dlg-button="btn-dlgModal-ok" class="btn btn-primary">Save</button>
			</div>
		</div>
	</div>
</div>