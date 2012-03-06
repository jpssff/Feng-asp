/** 
 *           File:  js\jquery.snippets.html.js
 *         Author:  Feng Weifeng(jpssff@gmail.com)
 *       Modifier:  Feng Weifeng(jpssff@gmail.com)
 *       Modified:  2011-08-26 19:48:21  
 *    Description:  html缩写表
 *      Copyright:  (c) 2011-2021 wifeng.cn
 */
(function(){
    var map = {
        'a' : '<a href="^!"></a>',
        'at' : '<a target="_blank" href="^!"></a>',
        'dl' : '<dl>\n\t<dt>^!</dt>\n\t<dd></dd>\n</dl>',
        'html' : '<!DOCTYPE html>\n<html>\n<head>\n<meta http-equiv="Content-Type" content="text/html;charset=utf-8">\n<title>Title</title>\n</head>\n<body>\n^!\n</body>\n</html>',
        'link' : '<link rel="stylesheet" href="^!" type="text/css" />',
        'scriptsrc' : '<script src="^!"></script>',
        'style' : '<style type="text/css">^!</style>',
        'ul' : '<ul>\n\t<li>^!</li>\n</ul>',
        'br' : '<br/>'
    }

    var tags = 'abbr address area article aside b blockquote body button canvas caption center cite code col colgroup command dd del details dfn dir div em fieldset figcaption figure font footer form h1 head header hgroup i iframe img input ins keygen isindex kbd label legend li link map mark menu meta meter nav noframes noscript object ol optgroup option output p param pre progress q rp rt ruby s samp script section select small source span strike strong style sub summary sup table tbody td textarea tfoot th thead time title tr tt u var video'.split(' ');

    $.each(tags, function(i, t){
        map[t] = '<' + t + '>^!</' + t + '>';
        map[t+'c'] = '<' + t + ' class="^!"></' + t + '>';
        map[t+'id'] = '<' + t + ' id="^!"></' + t + '>';
    });

    $.snippets('html',map);
})(jQuery);
