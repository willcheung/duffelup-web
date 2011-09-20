/***************************************************** 	
		Duffel Clip-It Bookmarklet 
		Copyright 2010, Duffel Inc. All Rights Reserved. 
******************************************************/

Clip.constants = {
	maxUrlIELength: 2048,
	maxUrlLength: 8192,
	isIE :(navigator.appVersion.indexOf("MSIE", 0) != -1),
	isSafari :(navigator.appVersion.indexOf("WebKit", 0) != -1)
};

function Clip(aWindow) {
	this.initClip(aWindow.document.title, aWindow.document.location, aWindow);
	this.fullPage = false;
}


Clip.prototype.initClip = function(title, url, window) {
	this.title = title;
	this.url = url;
	this.window = window;
}

Clip.prototype.setClipperURL = function(clipperURL) {
	if (this.url.protocol.indexOf("https") == 0
			&& clipperURL.indexOf("http:") == 0
			&& clipperURL.indexOf(':', 6) == -1) {
		clipperURL = "https:" + clipperURL.substring(5, clipperURL.length);
	}
	this.clipperURL = clipperURL;
}

Clip.prototype.getImages = function(url) {
	var objs = document.getElementsByTagName('img');
	var retArr = [];
	if(objs != null) {
		for(var j = 0; j < objs.length; j++) {
			var src = objs[j].getAttribute('src');
			if(src != null && objs[j].width > 115 && objs[j].height > 115) {
				if(src.substr(0, 7) != 'http://' && src.substr(0, 8) != 'https://') {
					if(src.substr(0, 1) == '/') {
						src = 'http://' + location.hostname + src;
						retArr.push(src);
						continue;
					} 
					if(src.substr(0, 3) == '../') {
						src = src.replace(new RegExp("\\.\\.\\/", 'g'), '');
						src = url+src;
						retArr.push(src);
						continue;
					}
					src = 'http://' + location.hostname + "/" + src;
					retArr.push(src);
					continue;
				}
				retArr.push(src);
			}
		}
	}
	return retArr.join('||');
}

Clip.prototype.showClipperPanel = function() {

	if(typeof CLIP_URL != "undefined" && CLIP_URL) {
		var _s_url = CLIP_URL;
	} else {
		var _s_url = location.href;
	}

	if(typeof CLIP_TITLE != "undefined" && CLIP_TITLE) {
		var _s_title = CLIP_TITLE;
	} else {
		var _s_title = document.title;
	}	

	if(typeof CLIP_NOTES != "undefined" && CLIP_NOTES) {
		var _s_sel = CLIP_NOTES;
	} else {
		var _s_sel = this.clipSelection() ? this.content : "";
		_s_sel = _s_sel.replace(/<\/?[^>]+(>|$)/g, '');
		_s_sel = _s_sel.replace(/\f{2,}|\r{2,}|\t{2,}|\v{2,}|\u00A0{2,}|\u2028{2,}|\u2029{2,}]/g, '');
		_s_sel = _s_sel.replace(/\n{2,}/g, '\n');	
		_s_sel = _s_sel.replace(/&#821(6|7);/g, '\'');
		_s_sel = _s_sel.replace(/&#822(0|1);/g, '"');
	}		
	
	if(typeof CLIP_ADDRESS != "undefined" && CLIP_ADDRESS) {
		var _s_address = CLIP_ADDRESS;
	} else {
		if (document.getElementsByTagName('address').item(0)) {
			var s = document.getElementsByTagName('address').item(0).innerHTML;
			s = s.replace(/^\s+|\s+$/g, '');
			s = s.replace(/&(lt|gt);/g, function (strMatch, p1) {
				return (p1 == 'lt') ? '<': '>'
			});
			var _s_address = s.replace(/<\/?[^>]+(>|$)/g, ' ');
		} else {
			var _s_address = '';
		}	
	}	
	
	if(typeof CLIP_PHONE != "undefined" && CLIP_PHONE) {
		var _s_phone = CLIP_PHONE;
	} else {
		var _s_phone = ''; // for future
	}
	
	if(typeof CLIP_TYPE != "undefined" && CLIP_TYPE) {
		var _s_type = CLIP_TYPE;
	} else {
		var _s_type = ''; // for future
	}			
	
	if(typeof PID != "undefined" && PID) {
		var _s_pid = PID;
	} else {
		var _s_pid = ''; // for future
	}	

	if(typeof NO_IMG != "undefined" && NO_IMG) {
		var _s_no_img = NO_IMG;
	} else {
		var _s_no_img = ''; // for future
	}	
	

	var img = this.getImages(_s_url);
	
	var url = this.clipperURL + '/research/new?idea_website='+encodeURIComponent(_s_url)+'&amp;event_title='+encodeURIComponent(_s_title)+'&amp;idea_address='+encodeURIComponent(_s_address)+'&amp;selection='+encodeURIComponent(_s_sel)+'&amp;idea_phone='+encodeURIComponent(_s_phone)+'&amp;type='+encodeURIComponent(_s_type)+'&amp;pid='+encodeURIComponent(_s_pid)+'&amp;img='+encodeURIComponent(img)+'&amp;no_img='+encodeURIComponent(_s_no_img)+'&amp;jump=doclose&amp;v=2';

	if((Clip.constants.isIE && _s_sel && url.length > Clip.constants.maxUrlIELength) ||
	(!Clip.constants.isIE && _s_sel && url.length > Clip.constants.maxUrlLength)) {
		alert("Oops, we can't clip so much text! Please select a smaller portion of text.");
	} else {
		var panel;
		panel = this.div("e_clipper");
		panel.style.position = "absolute";
		panel.style.right = "0px";
		panel.style.zIndex = 100000;
		panel.style.margin = "10px";
		panel.style.top = this.scrollTop(this.window) + "px";
	
		var data;
		data = this.div("e_data", panel);
		data.style.position = "absolute";
		data.style.width = "0px";
		data.style.height = "0px";
		data.style.zIndex = 0;
		data.style.margin = "0px";
		data.style.top = "0px";

		var view;
		view = this.div("e_view", panel);
		view.style.backgroundColor = "white";
		view.style.zIndex = 2;
		view.style.width = "500px";
		view.style.height = "345px";
		view.style.border = "1px solid black";
		view.innerHTML = '<iframe id="e_iframe" '
				+ 'onLoad="p = document.getElementById(\'e_data\'); c = p.style.zIndex; if (c==7) {;p.parentNode.parentNode.removeChild(p.parentNode);} p.style.zIndex = ++c;" '
				+ 'name="e_iframe" src="'+url+'" scrolling="no" frameborder="0" style="width:100%; height:100%; '
				+ 'border:1px; padding:0px; margin:0px"></iframe>';
		this.window.document.body.appendChild(panel);
		
		CLIP_URL = '';
		CLIP_TITLE = '';
		CLIP_NOTES = '';
		CLIP_ADDRESS = '';
		CLIP_PHONE = '';	
		CLIP_TYPE = '';	
		PID = '';
		_s_showed = true;
	}
}

Clip.prototype.scrollTop = function() {
	return this
			.filterResults(
					this.window.pageYOffset ? this.window.pageYOffset : 0,
					this.window.document.documentElement ? this.window.document.documentElement.scrollTop
							: 0,
					this.window.document.body ? this.window.document.body.scrollTop
							: 0);
}

Clip.prototype.filterResults = function(n_win, n_docel, n_body) {
	var n_result = n_win ? n_win : 0;
	if (n_docel && (!n_result || (n_result > n_docel)))
		n_result = n_docel;
	return n_body && (!n_result || (n_result > n_body)) ? n_body : n_result;
}

Clip.prototype.makeElement = function(elementName, parentElement) {
	var element;
	element = this.window.document.createElement(elementName);
	if (parentElement) {
		parentElement.appendChild(element);
	}
	return element;
}

Clip.prototype.div = function(id, parentElement) {
	var d = this.makeElement("div", parentElement);
	d.id = id;
	d.style.border = "0";
	d.style.margin = "0";
	d.style.padding = "0";
	d.style.position = "relative";

	return d;
}

Clip.prototype.HTMLEncode = function(str) {
	var result = "";
	for ( var i = 0; i < str.length; i++) {
		var charcode = str.charCodeAt(i);
		var aChar = str[i];
		if (charcode > 0x7f) {
			//result += "&#" + charcode + ";";
			result += str[i];
		} else if (aChar == '>') {
			result += "&gt;";
		} else if (aChar == '<') {
			result += "&lt;";
		} else if (aChar == '&') {
			result += "&amp;";
		} else {
			result += str[i];
		}
	}
	return result;
}

Clip.prototype.getRangeObject = function(selectionObject) {
	if (selectionObject.getRangeAt) {
		if (selectionObject.rangeCount == 0)
			return null;
		var r = selectionObject.getRangeAt(0);
		if (r.startContainer == r.endContainer && r.startOffset == r.endOffset) {
			return null;
		}
		return r;
	} else {
		var range = this.window.document.createRange();
		range
				.setStart(selectionObject.anchorNode,
						selectionObject.anchorOffset);
		range.setEnd(selectionObject.focusNode, selectionObject.focusOffset);
		return range;
	}
}

Clip.prototype.clipSelection = function() {
	var result = this.clipSelectionFromWindow(this.window);
	return result;
}

Clip.prototype.clipSelectionFromWindow = function(aWindow) {
	if (aWindow == null || aWindow.document == null
			|| aWindow.document.body == null) {
		return false;
	}
	var userSelection = null;
	var range = null;

	try {
		if (Clip.constants.isIE == false && aWindow.getSelection) {
			userSelection = aWindow.getSelection();
			if (userSelection  && userSelection.type != 'text') {
			}
		} else if (aWindow.document.selection) { // should come last; Opera!
			if (aWindow.document.selection.type != 'text') {
				userSelection = null;
			}
			if (Clip.constants.isIE) {
				userSelection = aWindow.document.selection.createRange();
			} else {
				userSelection = document.selection.createRange();
			}
		}
	} catch (e) {
		return false;
	}
	if (userSelection != null) {
		if (Clip.constants.isIE) {
			if (userSelection.htmlText.length > 0) {
				this.content = userSelection.htmlText;
				this.window = aWindow;
				return true;
			}
		} else {
			range = this.getRangeObject(userSelection);
			if (range != null) {
				this.content = this.DOMtoHTML(range.cloneContents());
				this.window = aWindow;
				return true;
			}
		}
		// Recurse
		for ( var i = 0; i < aWindow.frames.length; i++) {
			var aFrame = aWindow.frames[i];
			if (aFrame != null) {
				try {
					var success = this.clipSelectionFromWindow(aFrame);
					if (success) {
						return content;
					}
				} catch (e) {
					;
				}
			}
		}
	}
	return false;
}

Clip.prototype.DOMtoHTML = function(n) {
	if (Clip.constants.isIE) {
		return n.innerHTML;
	} else {
		return this.serializeDOMNode(n);
	}
}

Clip.prototype.serializeDOMNode = function(n) {
	var v = "";
	if (n == null)
		return v;
	var hasTag = (n.nodeType == 1) && (n.nodeName.indexOf('#') != 0);
	var name = "";
	if (n.nodeType == 3) { // Text block
		v += this.HTMLEncode(n.nodeValue);
	} else if (n.nodeType == 1) { // Element tag
		if (hasTag) {
			name = n.nodeName;
			v += '<' + name;
			var attrs = n.attributes;
			if (attrs != null) {
				for ( var i = 0; i < attrs.length; i++) {
					if (attrs[i].nodeValue != null
							&& attrs[i].nodeValue.length > 0)
						v += ' ' + attrs[i].nodeName + '=' + '"'
								+ attrs[i].nodeValue + '" ';
				}
			}
			v += '>';

		}
	}
	if (n.hasChildNodes()) {
		var children = n.childNodes;
		for ( var j = 0; j < children.length; j++) {
			try {
				var child = children[j];
				if (child != null && child.nodeType > 0
						&& child.nodeName != 'SCRIPT'
						&& child.nodeName != 'IFRAME') {
					v += this.serializeDOMNode(child);
				}
			} catch (e) {
				;
			}
		}
	}
	if (hasTag) {
		v += '</' + name + '>';
	}
	return v;
}

function EN_clip(clipURL) {
	var clipManager = new ClipManager(clipURL);
	clipManager.submit();
}

function ClipManager(clipURL) {
	var aWindow = null;
	try {
		aWindow = (window_clipped_to_en) ? window_clipped_to_en : window;
	} catch (e) {
		aWindow = window;
	}

	this.clip = new Clip(aWindow);
	this.clip.setClipperURL(clipURL);
}

ClipManager.prototype.submit = function() {
	this.clip.showClipperPanel();
}

try {
	EN_clip(EN_CLIP_HOST);
} catch (e) {
	//console.log(e);
}