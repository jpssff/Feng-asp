<%
//用于测试
bind('test', {
    index: function(){
        echo(F.desc(
            [F, 'F'], 
            [Object.prototype, 'Object.prototype'],
            [Function.prototype, 'Function.prototype'],
            [Array.prototype, 'Array.prototype'], 
            [String.prototype, 'String.prototype'], 
            [Number.prototype, 'Number.prototype'],
            [Date.prototype, 'Date.prototype']
            )
            );
        },

        markdown: function(){
            echo(F.markdown('\t:::html\tvare aa \t asdasd'));
        }
});
// vim:ft=javascript
%>

