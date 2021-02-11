<statistics>
</statistics>
<script>
google.charts.load('current', {'packages':['corechart']});
//google.charts.setOnLoadCallback(drawChart);

function drawChart(arr) {
	var data = google.visualization.arrayToDataTable(arr);

	var options = {
		title: 'Activity of users',
		curveType: 'function',
		legend: { position: 'bottom' },
		isStacked: true
	};

	var chart = new google.visualization.ColumnChart(document.getElementById('activityChart'));
	chart.draw(data, options);
}
      
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
					overal = ls.data.overal;
					depth = ls.data.depth;
					users = ls.data.users;
					activity = ls.data.activity;
					$("statistics").html("Number of lexemes: " + overal.all_dict + "<br>Remain lexemes: " + overal.remain_dict+"<br><br>");
					for (dind in depth){
						$("statistics").append("Draft count: " + depth[dind].draft_count + "; Lexemes count: " + depth[dind].lexemes + "<br>");
					}
					for (uind in users){
						$("statistics").append("User: " + users[uind].user + "; saved_drafts: " + users[uind].saved_drafts + "<br>");
					}
					$("statistics").append("<div id='activityChart'></div>");
					for (i in  activity) {
						activity[i][0] = new Date(activity[i][0]);
					}
					drawChart(activity);
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