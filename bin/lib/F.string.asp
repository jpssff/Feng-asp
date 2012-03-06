<%
F.namespace('F.string');
%>
<!--#include file="thirdparty/md5.asp"-->
<!--#include file="thirdparty/markdown.asp"-->
<%
//已在md5中扩展了以下函数
//F.hex_md5 = hex_md5;
//F.b64_md5 = b64_md5;
//F.str_md5 = str_md5;
//F.hex_hmac_md5 = hex_hmac_md5;
//F.b64_hmac_md5 = b64_hmac_md5;
//F.str_hmac_md5 = str_hmac_md5;
F.string.base64Encode = function(str) {
    var b64ch = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".split("");
    var b64 = "", b = 0, len = str.length;
    for (var i = 0; i < len; i++) {
        b = str.charCodeAt(i) << 16 & 0xFF0000;
        b |= str.charCodeAt(++i) << 8 & 0xFF00;
        b |= str.charCodeAt(++i) & 0xFF;
        b64 += b64ch[b >>> 18];
        b64 += b64ch[b >>> 12 & 0x3F];
        b64 += b64ch[b >>> 6 & 0x3F];
        b64 += b64ch[b & 0x3F];
    }
    if (len % 3 == 1) {
        b64 = b64.slice(0, -2) + "==";
    } else if (len % 3 == 2) {
        b64 = b64.slice(0, -1) + "=";
    }
    return b64;
};


F.string.base64Decode = function(b64) {
    var b64ch = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    var str = "", len = 0, unit = "", b = 0;
    b64 = b64.replace(/[^\d\w\+\/]/g, "");
    len = b64.length;
    for (var i = 0; i < len; i++) {
        b = b64ch.indexOf(b64.charAt(i)) << 18;
        b |= b64ch.indexOf(b64.charAt(++i)) << 12;
        b |= b64ch.indexOf(b64.charAt(++i)) << 6;
        b |= b64ch.indexOf(b64.charAt(++i));
        unit = (b | 0x1000000).toString(16);
        str += "%" + unit.substr(1, 2)
        str += "%" + unit.substr(3, 2)
        str += "%" + unit.substr(5, 2);
    }
    if (len % 4) {
        str = str.slice(0, (len % 4 - 4) * 3);
    }
    return unescape(str);
};


F.string.base64EncodeUTF8 = function(str) {
    var b64ch = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".split("");
    var utf8 = unescape(encodeURIComponent(str));
    var b64 = "", b = 0, len = utf8.length;
    for (var i = 0; i < len; i++) {
        b = utf8.charCodeAt(i) << 16;
        b |= utf8.charCodeAt(++i) << 8;
        b |= utf8.charCodeAt(++i);
        b64 += b64ch[b >>> 18];
        b64 += b64ch[b >>> 12 & 0x3F];
        b64 += b64ch[b >>> 6 & 0x3F];
        b64 += b64ch[b & 0x3F];
    }
    if (len % 3 == 1) {
        b64 = b64.slice(0, -2) + "==";
    } else if (len % 3 == 2) {
        b64 = b64.slice(0, -1) + "=";
    }
    return b64;
};


F.string.base64DecodeUTF8 = function(b64) {
    var b64ch = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    var str = "", len = 0, unit = "", b = 0;
    b64 = b64.replace(/[^\d\w\+\/]/g, "");
    len = b64.length;
    for (var i = 0; i < len; i++) {
        b = b64ch.indexOf(b64.charAt(i)) << 18;
        b |= b64ch.indexOf(b64.charAt(++i)) << 12;
        b |= b64ch.indexOf(b64.charAt(++i)) << 6;
        b |= b64ch.indexOf(b64.charAt(++i));
        unit = (b | 0x1000000).toString(16);
        str += "%" + unit.substr(1, 2)
        str += "%" + unit.substr(3, 2)
        str += "%" + unit.substr(5, 2);
    }
    if (len % 4) {
        str = str.slice(0, (len % 4 - 4) * 3);
    }
    return decodeURIComponent(str);
};

F.string.base64EncodeUTF16 = function(str) {
    var b64ch = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".split("");
    var b64 = "", b = [], len = str.length;
    for (var i = 0; i < len; i++) {
        b[0] = str.charCodeAt(i) << 8;
        b[1] = str.charCodeAt(++i);
        b[0] |= b[1] >>> 8;
        b[1] = b[1] << 16 & 0xFF0000 | str.charCodeAt(++i);
        b64 += b64ch[b[0] >>> 18];
        b64 += b64ch[b[0] >>> 12 & 0x3F];
        b64 += b64ch[b[0] >>> 6 & 0x3F];
        b64 += b64ch[b[0] & 0x3F];
        b64 += b64ch[b[1] >>> 18];
        b64 += b64ch[b[1] >>> 12 & 0x3F];
        b64 += b64ch[b[1] >>> 6 & 0x3F];
        b64 += b64ch[b[1] & 0x3F];
    }
    if (len % 3 == 1) {
        b64 = b64.slice(0, -5) + "=";
    } else if (len % 3 == 2) {
        b64 = b64.slice(0, -2) + "==";
    }
    return b64;
};


F.string.base64DecodeUTF16 = function(b64) {
    var b64ch = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    var str = unit = ch = "", len = loop = b = 0;
    b64 = b64.replace(/[^\d\w\+\/]/g, "");
    len = b64.length;
    for (var i = 0; i < len; i++) {
        b = b64ch.indexOf(b64.charAt(i)) << 18;
        b |= b64ch.indexOf(b64.charAt(++i)) << 12;
        b |= b64ch.indexOf(b64.charAt(++i)) << 6;
        b |= b64ch.indexOf(b64.charAt(++i));
        unit = (b | 0x1000000).toString(16);
        if (ch && i < len) {
            str += "%u" + ch + unit.substr(1, 2)
            str += "%u" + unit.substr(3, 4);
            ch = "";
        } else if (ch) {
            str += "%u" + ch + unit.substr(1, 2)
        } else {
            str += "%u" + unit.substr(1, 4);
            ch = unit.substr(5, 2);
        }
    }
    return unescape(str);
};

// vim:ft=javascript
%>
