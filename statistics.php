<statistics>
</statistics>
<script>
function getStat() {
	showLoading();
	var p = $.post("apiGetStatistics.php", {
		username: $("#username").val(),
		password: $("#password").val(),
		language: $("#language").val(),
        timezone: $("#timezone").val()
    },
	function(data, status){
		hideLoading();
		switch (status) {
			case "success":
                ls = JSON.parse(data);
                //debugger;
                if ('OK'== ls.result) {
					$("statistics").html("Number of lexemes: " + ls.data.all_dict + "<br>Remain lexemes: " + ls.data.remain_dict + "<br>Drafts: " + ls.data.drafts);
					
					dc = JSON.parse(ls.data.drafts);
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
}    
getStat();
</script>