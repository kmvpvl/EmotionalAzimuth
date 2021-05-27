<overview>
    <assigns>
    </assigns>
</overview>
<script>
drawAssigns();
function drawAssigns() {
    $('assigns').append(EAAssign.getHeader());
	for (const [ind, val] of Object.entries(eaUser.assigns)) {
		var $a = $('<assign/>');
		var a = new EAAssign(val, $a);
		a.draw();
		$('assigns').append($a);
        a.on('action', function(obj, data){
            switch(data.action) {
                case 'start':
                    obj.on('started', function(obj, data){
                        execAssign(obj.id);
                    });
                    obj.doStartStop(1);
                    break;
                default:
            }
        });
	}
}
</script>