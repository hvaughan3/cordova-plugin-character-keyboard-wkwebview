var argscheck = require('cordova/argscheck'),
utils = require('cordova/utils'),
exec = require('cordova/exec');

var CharacterKeyboard = function() { };

CharacterKeyboard.getActiveElementType= function(){
	return document.activeElement.type;
};

////// Decimals

CharacterKeyboard.isDecimal = function(){
	var showDecimal = null;
	var activeElement = document.activeElement;
	if(activeElement.attributes["decimal"]==undefined ||
		activeElement.attributes["decimal"]=='undefined' ||
		activeElement.attributes["decimal"].value=='false'){
		showDecimal = false;
	}else{
		showDecimal = true;
	}
	return showDecimal;
};

CharacterKeyboard.getDecimalChar = function(activeElement){
	if(activeElement==undefined || activeElement==null || activeElement=='undefined')
		activeElement = document.activeElement;

	var decimalChar = null;
	if(activeElement.attributes["decimal-char"]==undefined ||
		activeElement.attributes["decimal-char"]=='undefined'){
		decimalChar='.'
	}else{
		decimalChar=activeElement.attributes["decimal-char"].value;
	}
	return decimalChar;
};

CharacterKeyboard.addDecimalAtPos = function(val,position){ };

CharacterKeyboard.addDecimal = function(){
	var activeElement = document.activeElement;
	var allowMultipleDecimals = true;
	if(activeElement.attributes["allow-multiple-decimals"]==undefined ||
		activeElement.attributes["allow-multiple-decimals"]=='undefined' ||
		activeElement.attributes["allow-multiple-decimals"].value=='false'){
		allowMultipleDecimals = false;
	}
	var value = activeElement.value;
	var valueToSet = '';
	var decimalChar = CharacterKeyboard.getDecimalChar(activeElement);
	var caretPosStart = activeElement.selectionStart;
	var caretPosEnd = activeElement.selectionEnd;
	var first='';
	var last='';

	first = value.substring(0, caretPosStart);
	last = value.substring(caretPosEnd);

	if(allowMultipleDecimals){
		valueToSet = first+decimalChar+last;
	}else{
		if(value.indexOf(decimalChar) > -1)
			return;
		else{
			if(caretPosStart==0){
				first='0';
			}
			valueToSet = first+decimalChar+last;
		}
	}

    activeElement.value = valueToSet;
};

////// Dashes

CharacterKeyboard.isDash = function(){
	var showDash = null;
	var activeElement = document.activeElement;
	if(activeElement.attributes["dash"]==undefined ||
		activeElement.attributes["dash"]=='undefined' ||
		activeElement.attributes["dash"].value=='false'){
		showDash = false;
	}else{
		showDash = true;
	}
	return showDash;
};

CharacterKeyboard.getDashChar = function(activeElement){
	if(activeElement==undefined || activeElement==null || activeElement=='undefined')
		activeElement = document.activeElement;

	var dashChar = null;
	if(activeElement.attributes["dash-char"]==undefined ||
		activeElement.attributes["dash-char"]=='undefined'){
		dashChar='-'
	}else{
		dashChar=activeElement.attributes["dash-char"].value;
	}
	return dashChar;
};

CharacterKeyboard.addDashAtPos = function(val,position){ };

CharacterKeyboard.addDash = function(){
	var activeElement = document.activeElement;
	var allowMultipleDashes = true;
	if(activeElement.attributes["allow-multiple-dashes"]==undefined ||
		activeElement.attributes["allow-multiple-dashes"]=='undefined' ||
		activeElement.attributes["allow-multiple-dashes"].value=='false'){
		allowMultipleDashes = false;
	}
	var value = activeElement.value;
	var valueToSet = '';
	var dashChar = CharacterKeyboard.getDashChar(activeElement);
	var caretPosStart = activeElement.selectionStart;
	var caretPosEnd = activeElement.selectionEnd;
	var first='';
	var last='';

	first = value.substring(0, caretPosStart);
	last = value.substring(caretPosEnd);

	if(allowMultipleDashes){
		valueToSet = first+dashChar+last;
	}else{
		if(value.indexOf(dashChar) > -1)
			return;
		else{
			if(caretPosStart==0){
				first='0';
			}
			valueToSet = first+dashChar+last;
		}
	}

    activeElement.value = valueToSet;
};

module.exports = CharacterKeyboard;
