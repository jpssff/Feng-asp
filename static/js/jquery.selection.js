/** 
 *           File:  jquery.selection.js
 *         Author:  Feng Weifeng(jpssff@gmail.com)
 *       Modifier:  Feng Weifeng(jpssff@gmail.com)
 *       Modified:  2011-06-14 16:13:14  
 *    Description:  用于文本框的光标处理。针对IE6\7\8的\r\n做了兼容处理
 *      Copyright:  (c) 2011-2021 wifeng.cn
 */
(function($) {

	$.fn.getSelection = function() {
		var t = this[0];

		if ('selectionStart' in t) {
			var l = t.selectionEnd - t.selectionStart;
			return {
				start: t.selectionStart,
				end: t.selectionEnd,
				length: l,
				text: t.value.substr(t.selectionStart, l)
			};
		}

		else if (document.selection) {
			t.focus();
			var r = document.selection.createRange();
			if (r === null) {
				return {
					start: 0,
					end: e.value.length,
					length: 0,
					text: ''
				};
			}

			var sr = r.duplicate();

			//因为IE下，选区中会有\r\n, 而且还会将边界的\r\n自动trim掉
			//所以需要创建选区，通过比较还原真实的选区
			//创建range，将终点设置为选区的起点
			var range_1 = document.body.createTextRange();
			range_1.moveToElementText(t);
			range_1.setEndPoint("EndToStart", sr);

			var text1 = r_text1 = range_1.text,
			text = r_text = sr.text;
			var rn1 = rn = 0;

			var f1 = f = false;

			//步进还原选区
			do {
				if (!f1) {
					if (range_1.compareEndPoints('StartToEnd', range_1) === 0) {
						f1 = true;
					} else {
						range_1.moveEnd("character", - 1);
						if (text1 === range_1.text) {
							r_text1 += '\r\n';
							rn1++;
						} else {
							f1 = true;
						}
					}
				}
				if (!f) {
					if (sr.compareEndPoints('StartToEnd', sr) === 0) {
						f = true;
					} else {
						sr.moveEnd("character", - 1);
						if (text === sr.text) {
							r_text += '\r\n';
							rn++;
						} else {
							f = true;
						}
					}
				}
			} while (!f1 || ! f)

			//减去\r的个数，因为\r\n被作为一个字符处理
			var index = - 1,
			temp1 = 0,
			temp2 = 0;
			while ((index = text1.indexOf('\r', index + 1)) !== - 1) {
				temp1++;
			}

			index = - 1;
			while ((index = text.indexOf('\r', index + 1)) !== - 1) {
				temp2++;
			}

			var res = {
				start: text1.length + rn1 - temp1,
				end: text1.length + rn1 + text.length + rn - temp1 - temp2,
				length: r_text.length,
				text: r_text
			};

			return res;
		}
	};

	$.fn.setSelection = function(start, end) {
		start = parseInt(start) || 0;
		end = parseInt(end) || 0;
		if (end < start) {
			end = start;
		}

		return this.each(function() {
			if (document.selection) {
				var range = this.createTextRange();
				range.collapse(true);
				range.moveStart("character", start);
				range.moveEnd("character", end - start);
				range.select();
			} else if ('selectionStart' in this) {
				this.selectionStart = start;
				this.selectionEnd = end;
				this.focus();
			}
		});
	};

	$.fn.replaceSelection = function(text) {
		var t = this[0];
		if ('selectionStart' in t) {
			t.value = t.value.substr(0, t.selectionStart) + text + t.value.substr(t.selectionEnd);
		} else if (document.selection) {
			t.focus();
			document.selection.createRange().text = text;
		} else {
			t.value += text;
		}

		return this;
	}

})(jQuery)

