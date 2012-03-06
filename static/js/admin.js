function ajaxAction(action){
    $.get('?r=admin&a='+action, function(data){
        if(data.status == 0){
            $.tip('操作成功：' + data.msg);
        }else{
            $.alert('操作失败：' + data.msg);
        }
    }, 'json');
}
