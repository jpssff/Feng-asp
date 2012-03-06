(function(){
function G(id){return document.getElementById(id);}
function html_encode(s){return s.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;");}
function trim(s){return s.replace(/^\s+|\s+$/,'');}
function ajax(type, url, data, fn, fail){
    $.ajax({
        url: url,
        data: data,
        type: type,
        success: function(json){
            json = eval('(' + json + ')');
            if(json.status == 0){
                if(fn){
                    fn(json.msg);
                }else{
                    alert(json.msg);
                }
            }else{
                if(fail){
                    fail(json.msg);
                }else{
                    alert(json.msg);
                }
            }
        },
        error: function(){
            alert('发生网络错误');       
        }
    });
}
function ajaxGet(url, data, fn, fail){
    ajax('GET', url, data, fn, fail);
}
function ajaxPost(url, data, fn, fail){
    ajax('POST', url, data, fn, fail);
}
function comment_init(){
    var sbtn = G('commentc_btn');
    var doc = document;
    var _id = G('commentc_id'),
    _name = G('commentc_name'),
    _con = G('commentc_content'),
    _info = G('commentc_error'),
    _list = G('commentc_list');
    sbtn.onclick = start;
    //_con.onkeydown = trigger;
    _name.onkeydown = trigger;
    _name.onfocus = function(){
        _name.select();
    }

    function trigger(e){
        if(sbtn.disabled) return false;
        e = window.event || e;
        var k = e.keyCode || e.which;
        if(k == 13){
            start();
        }
    };

    function start(){
        var cl = _con.value.length;
        var nl = _name.value.length;
        if(cl<10 || cl.length>500 || nl<1 || nl.length>20){
            _info.style.display = 'block';
            return;
        }
        _info.style.display = 'none';
        sbtn.disabled = 'disabled';
        sbtn.value = '给力...';
        ajaxPost('/?r=comment&a=add',{
            'name' : _name.value,
            'content' : _con.value,
            'id' : _id.value
        },ok,error);
    }

    function ok(json){
        var c = _con.value,
        n = _name.value;
        _con.value = '';
        sbtn.value = '成功';
        var li = doc.createElement('li');
        li.innerHTML = '<span>(刚刚)</span><strong>'+html_encode(n)+'</strong>'+html_encode(c).replace(/\n+/g, '<br>');
        li.className = 'alert-message block-message info';
        _list.insertBefore(li,_list.firstChild);
        setTimeout(function(){
            sbtn.removeAttribute('disabled');
            sbtn.value = '评论';
        },1000);
        setTimeout(function(){
            li.className = 'alert-message block-message success';
        },10000);
    }

    function error(){
        sbtn.value = '失败';
        setTimeout(function(){
            sbtn.removeAttribute('disabled');
            sbtn.value = '评论';
        },1000);
    }
}
comment_init();
})();
