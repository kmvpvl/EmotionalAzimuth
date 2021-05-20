<exec-assign>
    <exec-toolbar-control>
    </exec-toolbar-control>
    <lexemes>
    </lexemes>
</exec-assign>
<script>
sendDataToServer('apiGetAssign', {id: <?=$_POST["data"]["id"]?>}, function(data, status){
    var ls = recieveDataFromServer(data, status);
    if (ls && ls.result=='OK') {
        var a = new EAAssign(ls.data, $('exec-toolbar-control'));
        a.draw();
        var s = new EASet(a.set_id, $('lexemes'));
        s.on('update', function(obj, data){
            obj.draw();
        });
    } else {
        showError("Object EAAssign damaged");
    }
});
</script>
