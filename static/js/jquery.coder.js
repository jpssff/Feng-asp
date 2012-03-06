/** 
 *           File:  js\jquery.coder.js
 *         Author:  Feng Weifeng(jpssff@gmail.com)
 *       Modifier:  Feng Weifeng(jpssff@gmail.com)
 *       Modified:  2011-06-20 09:33:38  
 *    Description:  将文本框变成一个编辑器。
 *      Copyright:  (c) 2011-2021 wifeng.cn
 */
(function($){
    $.fn.coder = function(opt){
        opt = $.extend(true, {}, {
            expandtab : true,    // 是否将tab转化为空格
            tabstop : 4,         // tab键对应的空格数
            cursorHolder : '^!', // 光标占位符
            fileType : 'html',   // 默认为html
            snippets : {},       // 默认没有任何代码片段
            autoindent: true,    // 是否自动缩进
            keyHandler : {},     // 扩展编辑器按键响应函数
            rangeHandler: {}     // 扩展选区按键响应
        }, opt);

        var $this = this;

        var CODER_KEY = 'WIFENG_CN_CODER', coder_data;

        //用于修改配置
        coder_data = $this.data(CODER_KEY)
        if(coder_data){
            $this.data(CODER_KEY, $.extend(coder_data, opt))
            return $this;
        }else{
            $this.data(CODER_KEY, opt);
        }

        var snippets = $.fn.coder._snippets;
        snippets[opt.fileType] = $.extend($.fn.coder._snippets[opt.fileType], opt.snippets);

        var dictionary = $.fn.coder._dictionary || {};

        //缩进字符
        var indentString = opt.expandtab ? new Array(opt.tabstop + 1).join(' ') : '\t';

        //状态
        var state = new State($this);

        var rangeHandler = {
            'Tab' : function($this, selection){
                indentLines($this, indentString, selection);
                state.add();
                return false;
            },

            'Shift-Tab' :function($this, selection){
                reindentLines($this, indentString);
                state.add();
                return false;
            },

            //大小写互换
            'Ctrl-K': function($this, selection){
                var text = selection.text;
                if(/[a-z]/.test(text)){
                    text = text.toUpperCase();
                }else{
                    text = text.toLowerCase();
                }
                $this.replaceSelection(text);
                $this.setSelection(selection.start, selection.end);
                return false;
            },

            //词首字母大写
            'Ctrl-Shift-U': function($this, selection){
                var text = selection.text;
                text = text.replace(/\b(\w)(\w*)\b/g, function(a, $1, $2){
                    return $1.toUpperCase() + $2.toLowerCase();
                });
                $this.replaceSelection(text);
                $this.setSelection(selection.start, selection.end);
                return false;
            }
        };

        var keyHandler = {
            //Tab键
            'Tab' : function($this, selection){
                //代码片段
                var word = getWordBeforeCursor($this, selection);
                if(snippets[opt.fileType] && (word in snippets[opt.fileType])){
                    state.add();
                    replaceSnippet($this, word, snippets, opt.fileType, indentString, opt.cursorHolder);
                    state.add();
                    return false;
                }
                //如果是设置了tab变空格
                if(opt.expandtab){
                    state.add();
                    $this.replaceSelection(indentString);
                    $this.setSelection(selection.start + indentString.length);
                    state.add();
                    return false;
                }
                //直接增加tab
                appendWords($this, selection.start, '\t');
                state.add();
                return false;
            },

            //注释行
            'Alt-Ctrl-/': function($this, selection){
                var cs = window.prompt('输入注释符号', '//');
                    indentLines($this, cs, selection);
                    return false;
            },

            //删除行注释
            'Ctrl-Shift-/': function($this, selection){
                var cs = window.prompt('输入注释符号', '//');
                    reindentLines($this, cs);
                    return false;
            },

            //向下补全
            'Ctrl-Down': function($this, selection){
                var word = getWordBeforeCursor($this, selection);
                if(word){
                    completeWord($this, selection, word, dictionary, 1);
                }
                return false;
            },

            'Ctrl-N': function($this, selection){
                return this['Ctrl-Down']($this, selection);
            },

            //向上补全
            'Ctrl-Up': function($this, selection){
                var word = getWordBeforeCursor($this, selection);
                if(word){
                    completeWord($this, selection, word, dictionary, -1);
                }
                return false;
            },

            //自动缩进
            'Enter': function($this, selection){
                if(opt.autoindent){
                    state.add();
                    var indentCount = getIndetCount($this.val(), selection.start, indentString);
                    if(indentCount > 0){
                        var str = '\n' + new Array(indentCount + 1).join(indentString);
                        appendWords($this, selection.start, str);
                        state.add();
                        return false;
                    }
                }
            },

            //运行代码
            'Ctrl-Enter': function($this, selection){
                try{
                    runCode($this);
                }catch(e){}
                $this.focus();
                return false;
            },

            //帮助
            'F1': function($this, selection){
                alert(
                    '** js coder ** \n\n' + 
                    'F1                -- 帮助\n' +
                    'Alt-Delete        -- 删除当前单词\n' +
                    'Alt-Shift-Delete  -- 删除当前行\n' +
                    'Alt-Shift-Down    -- 向下移动选中行\n' +
                    'Alt-Shift-Up      -- 向上移动选中行\n' +
                    'Alt-Ctrl-Right    -- 移动光标到下一编辑区\n' +
                    'Alt-Ctrl-Left     -- 移动光标到上一编辑区\n' +
                    'Ctrl-D            -- 插入日期\n' +
                    'Ctrl-M            -- 插入时间\n' +
                    'Ctrl-K            -- 切换大小写\n' +
                    'Ctrl-Shift-U      -- 单词首字符大写\n' +
                    'Ctrl-R            -- 选中当前行\n' +
                    'Alt-Ctrl-/        -- 注释行\n' +
                    'Ctrl-Shift-/      -- 去除注释\n' +
                    'Ctrl-Delete       -- 删除到当前单词尾\n' +
                    'Ctrl-Shift-Delete -- 删除至行尾\n' +
                    'Ctrl-J            -- 复制当前行\n' +
                    'Ctrl-Shift-J      -- 合并选中行\n' +
                    'Ctrl-Z            -- 撤销\n' +
                    'Ctrl-Y            -- 重做\n' +
                    'Ctrl-↓            -- 自动完成单词\n' +
                    'Ctrl-↑            -- 反向完成单词\n' +
                    'Tab               -- 缩进行,替换片段\n' +
                    'Shift-Tab         -- 反向缩进\n' +
                    'Ctrl-Enter        -- 新窗口运行代码\n\n' +
                    '@ 2011 by fengweifeng'
                );
                return false;
            },

            //撤销
            'Ctrl-Z': function($this, selection){
                state.undo();
                return false;
            },

            //重做
            'Ctrl-Y': function($this, selection){
                state.redo();
                return false;
            },

            //插入日期
            'Ctrl-D': function($this, selection){
                state.add();
                var s = '', d = new Date();
                s += d.getFullYear() + '/' + (d.getMonth()+1) + '/' + d.getDate();
                $this.replaceSelection(s);
                $this.setSelection(selection.start + s.length);
                state.add();
                return false;
            },

            //插入时间
            'Ctrl-M': function($this, selection){
                state.add();
                var s = '', d = new Date();
                s += d.getHours() + ':' + d.getMinutes();
                $this.replaceSelection(s);
                $this.setSelection(selection.start + s.length);
                state.add();
                return false;
            },

            //删除至行尾
            'Ctrl-Shift-Delete': function($this, selection){
                state.add();
                var value = $this.val();
                var end = value.indexOf('\n', selection.end);
                if(end === -1){
                    end = value.length;
                }
                $this.setSelection(selection.start, end).replaceSelection('');
                $this.setSelection(selection.start);
                return false;
            },

            //删除到当前单词结尾
            'Ctrl-Delete': function($this, selection){
                state.add();
                var value = $this.val().slice(selection.start);
                if(value.length){
                    var s = value.substring(0, 1);
                    var index = 1;
                    if(/\w/.test(s)){
                        index = value.search(/\W/);
                    }
                    $this.setSelection(selection.start, selection.start + index).replaceSelection('');
                    $this.setSelection(selection.start);
                    state.add();
                }
                return false;
            },

            //删除当前行
            'Alt-Shift-Delete': function($this, selection){
                state.add();
                var se = getLinesSelection($this, selection);
                $this.setSelection(se.lineStart, se.lineEnd + 1).replaceSelection('');
                $this.setSelection(se.lineStart);
                state.add();
                return false;
            },

            //删除当前单词
            'Alt-Delete': function($this, selection){
                state.add();
                var se = getWordSelection($this, selection);
                $this.setSelection(se.start, se.start === se.end ? se.end + 1 : se.end).replaceSelection('');
                $this.setSelection(se.start);
                state.add();
                return false;
            },

            //复制当前行
            'Ctrl-J': function($this, selection){
                state.add();
                var se = getLinesSelection($this, selection);
                var text = se.lineText + '\n' + se.lineText;
                $this.setSelection(se.lineStart, se.lineEnd).replaceSelection(text);
                $this.setSelection(se.lineStart + text.length);
                state.add();
                return false;
            },

            //合并行
            'Ctrl-Shift-J': function($this, selection){
                state.add();
                var se = getLinesSelection($this, selection);
                var single = se.lineText.indexOf('\n') === -1;
                if(single){
                    $this.setSelection(se.lineStart, se.lineEnd + 1);
                    se = getLinesSelection($this);
                }
                var n = 0;
                var text = se.lineText.replace(/\n/g, function(){
                    n ++;
                    return '';
                });
                $this.setSelection(se.lineStart, se.lineEnd).replaceSelection(text);
                $this.setSelection(se.lineStart, se.lineEnd - n);
                state.add();
                return false;
            },

            //向下移动选中行
            'Alt-Shift-Down': function($this, selection){
                state.add();
                var se = getLinesSelection($this, selection);
                $this.setSelection(se.lineStart, se.lineEnd + 1);
                var se2 = getLinesSelection($this);
                if(se2.lineEnd !== se.lineEnd){
                    var text = se2.lineText.slice(se.lineText.length + 1);
                    $this.setSelection(se2.lineStart, se2.lineEnd).replaceSelection(text + '\n' + se.lineText);
                    $this.setSelection(se.lineStart + text.length + 1, se2.lineEnd);
                    state.add();
                }else{
                    $this.setSelection(selection.start, selection.end);
                }
                return false;
            },

            //向上移动选中行
            'Alt-Shift-Up': function($this, selection){
                state.add();
                var se = getLinesSelection($this, selection);
                $this.setSelection(se.lineStart - 1, se.lineEnd);
                var se2 = getLinesSelection($this);
                if(se2.lineStart !== se.lineStart){
                    var text = se2.lineText.slice(0, se2.lineText.length - se.lineText.length - 1);
                    $this.setSelection(se2.lineStart, se2.lineEnd).replaceSelection(se.lineText + '\n' + text);
                    $this.setSelection(se2.lineStart, se2.lineStart + se.lineText.length);
                    state.add();
                }else{
                    $this.setSelection(selection.start, selection.end);
                }
                return false;
            },

            //选中当前行
            'Ctrl-R': function($this, selection){
                var se = getLinesSelection($this, selection);
                $this.setSelection(se.lineStart, se.lineEnd);
                return false;
            },

            //移动到下一个编辑区
            'Alt-Ctrl-Right': function($this, selection){
                var value = $this.val().substring(selection.start);
                var indexMatch = ['""', "''", '><'];
                var searchMatch = /\b((\w|\d)+)>(\n|\s)+<\/\1/;
                var index = [], temp;
                for(var i=0; i<indexMatch.length; i++){
                    temp = value.indexOf(indexMatch[i]);
                    if(temp > -1){
                        index.push(temp + 1);
                    }
                }
                temp = value.search(searchMatch);
                if(temp > -1){
                    temp = value.indexOf('<', temp)
                    index.push(temp);
                }
                if(index.length){
                    $this.setSelection(selection.start + Math.min.apply(null, index));
                }
                return false;
            },

            //移动到上一个编辑区
            'Alt-Ctrl-Left': function($this, selection){
                var value = $this.val().substring(0, selection.start);
                var indexMatch = ['""', "''", '><'];
                var searchMatch = /\b((\w|\d)+)>(\n|\s)+<\/\1/;
                var index = [], temp;
                for(var i=0; i<indexMatch.length; i++){
                    temp = value.lastIndexOf(indexMatch[i]);
                    if(temp > -1){
                        index.push(temp + 1);
                    }
                }
                var m = -1, v = value;
                while((temp = v.search(searchMatch) !== -1)){
                    m = temp;
                    v = v.substring(m);
                }
                temp = m;
                if(temp > -1){
                    temp = value.indexOf('<', temp)
                    index.push(temp);
                }
                if(index.length){
                    $this.setSelection(Math.max.apply(null, index));
                }
                return false;
            }
        };
        $.extend(keyHandler, opt.keyHandler);
        $.extend(rangeHandler, opt.rangeHandler);

        return $this.keydown(function(e){
            var action = getActionName(e);
            var selection = $this.getSelection();

            //如果选中文本
            if(selection.start !== selection.end){
                if(action in rangeHandler){
                    if(rangeHandler[action]($this, selection) === false){
                        return false;
                    }
                };
            }

            //执行对应的功能
            if(action in keyHandler){
                if(keyHandler[action]($this, selection) === false){
                    return false;
                }
            };

            //保存状态
            state.add();

            //让其他键正常使用
            return true;
        });
    };

    $.snippets = function(type, snippets){
        $.fn.coder._snippets[type] = snippets;
    };

    $.fn.coder._snippets = {};

    $.dictionary = function(data){
        $.fn.coder._dictionary = data;
    };

    //获取按键的字符串表示
    var getActionName = (function(){
        var specialKeys = {
            112 : 'F1',
            113 : 'F2',
            114 : 'F3',
            115 : 'F4',
            116 : 'F5',
            117 : 'F6',
            118 : 'F7',
            119 : 'F8',
            120 : 'F9',
            121 : 'F10',
            122 : 'F11',
            123 : 'F12',
            13  : 'Enter',
            144 : 'Num',
            144 : 'Numlock',
            145 : 'Scrolllock',
            187 : 'Plus',
            189 : 'Minus',
            19  : 'Break',
            19  : 'Pause',
            191 : '/',
            20  : 'Caps',
            20  : 'Capslock',
            27  : 'Esc',
            32  : 'Space',
            33  : 'Pageup',
            34  : 'Pagedown',
            35  : 'End',
            36  : 'Home',
            37  : 'Left',
            38  : 'Up',
            39  : 'Right',
            40  : 'Down',
            45  : 'Insert',
            46  : 'Delete',
            8   : 'Backspace',
            9   : 'Tab'
        };

        return function(e){
            var map = [];
            e.altKey && (map.push('Alt'));
            e.ctrlKey && (map.push('Ctrl'));
            e.shiftKey && (map.push('Shift'));
            if(e.keyCode > 64 && e.keyCode < 91){
                map.push(String.fromCharCode(e.keyCode));
            }else if(e.keyCode in specialKeys){
                map.push(specialKeys[e.keyCode]);
            }
            return map.join('-');
        };
    })();


    //自动完成单词
    function completeWord($this, selection, word, dict, dir){
        var coms = [], sugs, cache = completeWord.cache;
        var k = word.slice(0, 1);
        var ext = selection.text;
        //如果光标位置和单词都没变，则查缓存
        if(cache.start === selection.start && cache.word === word){
            coms = cache.data;
        }else{
            var map = getExistWrodsMap($this, selection, word);
            if(k in dict){
                sugs = getSuggestWords(word, dict[k]);
            }
            if(sugs.length){
                coms = sugs;
            }
            var i = 0;
            while(coms[i] !== undefined){
                if(coms[i] in map){
                    coms.splice(i, 1);
                    continue;
                }
                i++;
            }
            var temp = [];
            for(var i in map){
                temp.push(i);
            }
            temp = temp.sort();
            coms = temp.concat(sugs);

            //将此次查询放入缓存，提高补全效率
            cache.word = word;
            cache.start = selection.start;
            cache.data = coms;
        }
        if(coms.length){
            var sug = fetchSuggest(word, coms, ext, dir);
            var se = selection;
            appendWords($this, se.start, sug);
            $this.setSelection(se.start, se.start + sug.length);
        }
    }
    completeWord.cache = {word:'', start:0, data: []};

    //获取已经存在的单词
    function getExistWrodsMap($this, selection, word){
        var map = {};
        var value = $this.val();
        value = value.substring(0, selection.start - word.length) + ' ' + value.substr(selection.end);
        var words = value.split(/\W/), temp;
        for(var i=0, l=words.length; i<l; i++){
            temp = words[i];
            if(temp === ''){
                continue;
            }
            if(temp in map){
                continue;
            }else{
                if(temp.length > 1 && temp !== word && temp.indexOf(word) === 0){
                    map[temp] = null;
                }
            }
        }
        return map;
    }

    //取出一个词
    function fetchSuggest(w, sugs, ext, dir){
        var t = w + ext, index = -1, l=sugs.length;
        for(var i=0; i<l; i++){
            if(sugs[i] === t){
                index = i;
                break;
            }
        }
        return sugs[(index + (1*dir) + l)%l].slice(w.length);
    }

    //返回匹配的词组
    function getSuggestWords(w, dict){
        var res = [];
        for(var i=0, l=dict.length; i<l; i++){
            var index = dict[i].indexOf(w);
            if(index === 0){
                res.push(dict[i]);
            }
        }
        return res;
    }

    //获取光标前的单词
    function getWordBeforeCursor($this, selection){
        if(!selection){
            selection = $this.getSelection();
        }
        var value = $this.val().substring(0, selection.start)
        var word = value.match(/\s*(\w+)$/);
        if(word && word.length){
            word = word.pop();
        }
        return word;
    }

    //替换字符串的缩进字符
    function replaceIndent(str, indentString){
        var pices = str.split(/\n/);
        for(var i=0; i<pices.length; i++){
            pices[i] = pices[i].replace(/^\t+/, function(ts){
                return new Array(ts.length + 1).join(indentString);
            });
        }
        return pices.join('\n');
    }

    //计算缩进次数
    function getIndetCount(value, start, indentString){
        if(indentString.length === 0)
            return 0;
        var subindex = value.substring(0, start).lastIndexOf('\n');
        var spaces = value.substring(subindex + 1, start).match(/^( |\t)+/);
        if(!spaces){
            return 0;
        }
        var space = spaces[0];
        var temp = space, s, count = 0;
        while((s = temp.replace(indentString, '')) !== temp){
            count ++;
            temp = s;
        }
        return count;
    }

    //在光标下插入文本
    function appendWords($t, start, words){
        $t.replaceSelection(words);
        $t.setSelection(start + words.length);
    }

    //替换片段
    function replaceSnippet($t, word, snippets, ft, indentString, cursorHolder){
        var $this = $t;
        var _this = $t[0];
        //如果有映射，则替换
        var snippet = snippets[ft][word];
        var se = $this.getSelection();
        var start = se.start - word.length;
        var end = se.start;

        //先将缩写词删除
        $this.setSelection(start, end).replaceSelection('');
        $this.setSelection(start);

        //缩进替换
        var insertValue = replaceIndent(snippet, indentString);

        //获取对照的缩进空白字符
        var indentCount = getIndetCount($this.val(), start, indentString);
        if(indentCount > 0){
            var space = new Array(indentCount + 1).join(indentString);
            insertValue = insertValue.replace(/\n/g, '\n' + space);
        }

        //插入替换文本
        $this.replaceSelection(insertValue);

        //替换光标占位符
        var cursor = start;
        var holderIndex = insertValue.indexOf(cursorHolder);
        if(holderIndex !== -1){
            cursor += holderIndex;
            $this.setSelection(cursor, cursor + cursorHolder.length).replaceSelection('');
        }else{
            cursor += snippet.length;
        }

        //摆正光标位置
        $this.setSelection(cursor);
    }

    //获取完整行的信息
    function getLinesSelection($t, selection){
        var $this = $t;
        var se = selection || $this.getSelection();
        var value = $this.val();
        var lastBr = value.substring(0, se.start).lastIndexOf('\n');
        if(lastBr > -1){
            se.lineStart = lastBr + 1;
        }else{
            se.lineStart = 0;
        }
        var nextBr = value.indexOf('\n', se.end);
        if(nextBr > -1){
            se.lineEnd = nextBr;
        }else{
            se.lineEnd = value.length;
        }
        se.lineText = value.substring(se.lineStart, se.lineEnd).replace(/\r/g, '');
        return se;
    }

    //获取单词信息
    function getWordSelection($t, selection){
        var $this = $t;
        var se = selection || $this.getSelection();
        var linese = getLinesSelection($this, se);
        var start = se.start - linese.lineStart, 
        end = start,
        line = linese.lineText;
        while(/\w/.test(line.charAt(start - 1))){
            start --;
        }
        while(/\w/.test(line.charAt(end))){
            end ++;
        }
        return {
            start:linese.lineStart + start, 
            end:linese.lineStart + end, 
            text:line.substring(start, end)
        };
    }

    //缩进多行
    function indentLines($t, indentString, selection){
        var $this = $t;
        var se = getLinesSelection($this, selection);
        var lines = se.lineText.split('\n');
        var temp = 0, step = indentString.length;
        for(var i=0, l=lines.length; i<l; i++){
            lines[i] = indentString + lines[i];
            temp += step;
        }
        $this.setSelection(se.lineStart, se.lineEnd).replaceSelection(lines.join('\n'));
        $this.setSelection(se.lineStart, se.lineEnd + temp);
    }

    //反缩进多行
    function reindentLines($t, indentString){
        var $this = $t;
        var se = getLinesSelection($this);
        var lines = se.lineText.split('\n');
        var temp = 0, step = indentString.length;
        for(var i=0, l=lines.length; i<l; i++){
            if(lines[i].indexOf(indentString) === 0){
                lines[i] = lines[i].slice(step);
                temp += step;
            }else if(lines[i].indexOf('\t') === 0){
                lines[i] = lines[i].slice(1);
                temp ++;
            }else if(lines[i].indexOf(' ') === 0){
                lines[i] = lines[i].replace(/^ +/g, function(s){
                    temp += s.length;
                    return '';
                });
            }
        }
        $this.setSelection(se.lineStart, se.lineEnd).replaceSelection(lines.join('\n'));
        $this.setSelection(se.lineStart, se.lineEnd - temp);
    }

    //运行代码
    function runCode($t){
        var code = $t.val();
        var win = window.open('', "_blank", '');
        win.document.open('text/html', 'replace');
        win.opener = null;
        win.document.write(code);
        win.document.close();
    }

    //状态管理器
    function State($t){
        this.MAX = 100;
        this.$t = $t;
        this.t = $t[0];
        this.current = 0;
        this.latest = 0;
        this.cache = new Array(this.MAX + 1);
        this.cache[0] = {value:$t.val(), selection:{start:0, end:0, text:''}, scroll:0};
        this.cache[-1] = {value:$t.val(), selection:{start:0, end:0, text:''}, scroll:$t[0].scrollTop};
        var o = this;

        //添加一个状态
        this.add = function(){
            if(this.$t.val() === this.cache[this.latest % this.MAX].value)
                return;
            if(this.latest !== this.current){
                this.latest = this.current + 1;
            }else{
                this.latest ++;
            }
            this.cache[this.latest % this.MAX] = {
                value : o.$t.val(),
                selection : $t.getSelection(),
                scroll : o.t.scrollTop
            };
            this.current = this.latest;
        };

        //撤销
        this.undo = function(){
            if(this.current === 0 || this.latest - this.current + 1 === this.MAX){
                this.update(-1);
                return;
            }
            this.current --;
            this.update(this.current);
        };

        //重做
        this.redo = function(){
            if(this.current === this.latest){
                return;
            }
            if(this.cache[(this.current+1)%this.MAX] !== undefined){
                this.current ++;
                this.update(this.current);
            }
        };

        //更新状态
        this.update = function(index){
            var v = this.cache[index % this.MAX];
            this.$t.val(v.value);
            this.t.scrollTop = v.scroll;
            this.$t.setSelection(v.selection.start, v.selection.end);
            this.t.focus();
        };
    }
})(jQuery);

