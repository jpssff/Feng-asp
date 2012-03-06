(function($){
    var __op, __opf, __opt;
    $.tip = function(html, autohide){
        autohide = autohide === undefined ? true : autohide;
        var doc = $(document), win = $(window);
        var tip = __op || (function(){
            tip = __op = $('<div>')
              .addClass('ui-state-highlight ui-corner-all')
              .appendTo(document.body)
              .append($('<span>').addClass('ui-icon ui-icon-info')
              .css({float:'left',marginRight:'0.3em',fontSize:'12px'}))
              .append('<span class="wi-tip-content">')
              .hide();
            tip.css({position:'fixed', _position:'absolute',padding:'0.5em',zIndex:'1000000'});
            tip.css({
                top:0,
                _top:doc.scrollTop(),
                left:(win.width() - doc.scrollLeft() - tip.width())/2
            });
            tip.ajaxStart(function(){
                tip.find('span.wi-tip-content').html('loading...');
                tip.show();
            });
            tip.ajaxStop(function(){
                if(!__opf){
                    tip.hide();
                }
            });
            return tip;
        })();
        if(html === undefined) return tip;
        __opf = true;
        __opt && (window.clearTimeout(__opt));
        var c = tip.find('.wi-tip-content').html(html);
        tip.stop(1,1).show().css('left', (win.width() - doc.scrollLeft() - tip.width())/2);
        __opt = window.setTimeout(function(){
            if(autohide){
                tip.slideUp('fast', function(){
                    __opf = false;
                });
            }
        }, 2000);
        return tip;
    };


    var _alert;
    $.alert = function(html, opt){
        opt = opt || {};
        _alert || (_alert = $('<div>'));
		_alert.html(html).dialog($.extend(opt, {
			buttons:{
				'确定': function(){
					opt.ok && opt.ok.call(this);
					_alert.dialog('close')
				}
			}
		}));
		return _alert;
    };


    var _confirm;
    $.confirm = function(html, opt){
        opt = opt || {};
        _confirm || (_confirm = $('<div>'));
        _confirm.html(html).dialog($.extend(opt, {
            buttons:
            {
                '确认': function(){
                    opt.ok && opt.ok.call(this);
                    _confirm.dialog('close')
                },

                '取消': function(){
                    opt.cancel && opt.cancel.call(this);
                    _confirm.dialog('close')
                }
            }
        }));
		return _confirm;
    };

    var _prompt;
    $.prompt = function(html, defaultValue, opt){
        opt = opt || {};
        _prompt || (_prompt = $('<div>'));
        var _input = $('<input style="width:95%;" type="text">').val(defaultValue || '');
        _prompt.html(html).append('<div style="height:5px;"></div>')
        .append(_input).dialog($.extend(opt, {
            buttons:
            {
                '确认': function(){
                    opt.ok && opt.ok.call(this, _input.val());
                    _prompt.dialog('close')
                },

                '取消': function(){
                    opt.cancel && opt.cancel.call(this, _input.val());
                    _prompt.dialog('close')
                }
            }
        }));
        _input.focus();
        _input.select();
		_input.keydown(function(e){
			if(e.keyCode === 13){
				opt.ok && opt.ok.call(this, _input.val());
				_prompt.dialog('close')
			}
	    });
		return _prompt;
    };

})(jQuery);
