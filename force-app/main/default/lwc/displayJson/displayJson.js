/* eslint-disable no-console */
import { LightningElement, api, track} from 'lwc';

export default class DisplayJson extends LightningElement {
    @api title;
    @api jsonValue;
    @api showLineNumbers;
    @api maxStringLength;
    @api sortObjects;
    @api setIcons;
    @api syntaxColor;
    @api stringColor;
    @api numberColor;
    @api booleanColor;
    @api keyColor;
    @api keywordColor;

    @track jsonString;
    @track errorMessage;
    initialRender = true;
    
    renderJson(){
        
        var numOfLines = 1;
        var showLineNumbers = this.showLineNumbers;
        var maxStringLength = this.maxStringLength;
        var sortObjects = this.sortObjects;
        var useDefaultIcons = (this.setIcons === "Up/Down Arrows") ? true : false;
        const newLineRegex = /\r\n|\r|\n/;
        const numberRegex = /\d/g;
        const finalLine = JSON.stringify(typeof this.jsonValue !== "string"? this.jsonValue : JSON.parse(this.jsonValue), undefined, 2).split(newLineRegex).length;

        var module, window, define,renderjson=(function() {

            var themetext = function(/* [class, text]+ */) {
                var spans = [];
                while (arguments.length)
                    spans.push(append(span(Array.prototype.shift.call(arguments)),
                                      text(Array.prototype.shift.call(arguments))));
                return spans;
            };
            var append = function(/* el, ... */) {
                var el = Array.prototype.shift.call(arguments);
                for (var a=0; a<arguments.length; a++)
                    if (arguments[a].constructor === Array)
                        append.apply(this, [el].concat(arguments[a]));
                    else
                        el.appendChild(arguments[a]);
                return el;
            };
            var prepend = function(el, child) {
                el.insertBefore(child, el.firstChild);
                return el;
            }
            var lengthOfNumber = function(numberString) {
                return numberString.toString().length;
            }
            // TODO: Are we using this
            var countSpaces = function(numOfLinesLocal){
                var sumSpaces = " ";
                for(var i = 0; i < (lengthOfNumber(finalLine) - lengthOfNumber(numOfLinesLocal)); i++) sumSpaces+=" ";
                return sumSpaces;
            }
            var isempty = function(obj, pl) {
                var keys = pl || Object.keys(obj);
                for (var i in keys) if (Object.hasOwnProperty.call(obj, keys[i])) return false;
                return true;
            }
            var text = function(txt) {
                return document.createTextNode(txt)
            };
            var span = function(classname) {
                var s = document.createElement("span");
                if (classname) s.className = classname;
                return s;
            };
            var A = function A(txt, classname, callback) {
                var a = document.createElement("a");
                if (classname) a.className = classname;
                a.appendChild(text(txt));
                a.href = 'javascript:void(0)';
                a.onclick = function(e) { callback(); if (e) e.stopPropagation(); return false; };
                return a;
           };

            function _renderjson(json, indent, dont_indent, show_level, options) {
                var my_indent = dont_indent ? "" : indent;

                var removeNumbers = function(value) {
                     return showLineNumbers ? value.replace(numberRegex, ""): value;
                }
                var removeNumbersAndThreeSpaces = function(value) {
                     return showLineNumbers ? value.replace(numberRegex, "").slice(0, -3): value;
                }
                var addNewNumbers = function() {
                     return showLineNumbers ? countSpaces(numOfLines) + numOfLines.toString() + " " : "";
                }
                var replaceLineNumberWithCurrent = function(value) {
                    return showLineNumbers ? addNewNumbers() + removeNumbers(value): value;
                }
                var disclosure = function(open, placeholder, close, type, builder) {
                var content;
                var empty = span(type);
                var show = function() {
                     if (!content) append(empty.parentNode, content = prepend(builder(), A(options.hide, "disclosure",
                                             function() { content.style.display="none";
                                                          empty.style.display="inline"; } )));
                    content.style.display="inline";
                    empty.style.display="none";
                };

                append(empty,
                       A(options.show, "disclosure", show),
                       themetext(type+ " syntax", open),
                       A(placeholder, null, show),
                       themetext(type+ " syntax", close));
                var el = append(span(), themetext('hide', my_indent.slice(0,-1)), empty);
                    if (show_level > 0 && type != "string")
                        show();
                return el;
            };

            if (json === null) {
                return themetext('hide', my_indent, "keyword", "null");
            }

            if (json === void 0) {
                return themetext('hide', my_indent, "keyword", "undefined");
            } 

            if (typeof(json) == "string" && json.length > options.max_string_length)
                return disclosure('"', json.substr(0,options.max_string_length)+" ...", '"', "string", function () {
                    return append(span("string"), themetext(null, my_indent, "string", JSON.stringify(json)));
                });

            if (typeof(json) != "object" || [Number, String, Boolean, Date].indexOf(json.constructor) >= 0) { // Strings, numbers and bools
                return themetext('hide', my_indent, typeof(json), JSON.stringify(json));
            }

            if (json.constructor == Array) {
                if (json.length == 0) return themetext(null, my_indent, "array syntax", "[]");

                return disclosure("[", options.collapse_msg(json.length), "]", "array", function () {
                    var as = append(span("array"), themetext("array syntax", "[", null, "\n"));
                    numOfLines++;
                    for (var i=0; i<json.length; i++) {
                        append(as, themetext('hide', addNewNumbers(), null, removeNumbers(indent) +"    "),
                               _renderjson(options.replacer.call(json, i, json[i]), indent+"    ", true, show_level-1, options),
                               i != json.length-1 ? themetext("syntax", ",") : [],
                               text("\n"));
                        numOfLines++;               }
                    if(numOfLines === finalLine)
                        append(as, themetext('hide', addNewNumbers(), null, removeNumbers(indent), "array syntax", " ]"));
                    else
                        append(as, themetext('hide', addNewNumbers(), null, removeNumbers(indent), "array syntax", "]"));

                    return as;
                });
            }

            // object
            if (isempty(json, options.property_list))
                return themetext(null, my_indent, "object syntax", "{}");

            return disclosure("{", options.collapse_msg(Object.keys(json).length), "}", "object", function () {
                var os = append(span("object"), themetext("object syntax", "{", null, "\n"));
                numOfLines++;

                for (var k in json)  var last = k;
                var keys = options.property_list || Object.keys(json);
                if (options.sort_objects)
                    keys = keys.sort();
                for (var i in keys) {
                    var k = keys[i];
                    if (!(k in json)) continue;
                    append(os, themetext('hide', addNewNumbers(), null, removeNumbers(indent) +"    ", "key", '"'+k+'"', "object syntax", ': '),
	                _renderjson(options.replacer.call(json, k, json[k]), indent+"    ", true, show_level-1, options),
	                k !== last ? themetext("syntax", ",") : [],
	                text("\n")); 
                    numOfLines++; }

                //TODO: change the below indent to count spaces
                if(numOfLines ===  finalLine)
                append(os, themetext('hide', addNewNumbers(), null, removeNumbers(indent), "object syntax", " }"));
                else
                append(os, themetext('hide', addNewNumbers(), null, removeNumbers(indent), "object syntax", "}"));
                return os;
            });
            }

            var renderjson = function renderjson(json)
            {
                var options = new Object(renderjson.options);
                options.replacer = typeof(options.replacer) == "function" ? options.replacer : function(k,v) { return v; };
                var pre = append(document.createElement("pre"), _renderjson(json, "", false, options.show_to_level, options));
                pre.className = "renderjson";
                if(showLineNumbers) {
                    //pre = prepend(pre, themetext(null, "    ")[0]);
                    pre = prepend(pre, themetext('hide', countSpaces(1) + "1 ")[0]);
                }
                return pre;
            }
            renderjson.set_icons = function(show, hide) { renderjson.options.show = show;
                                                      renderjson.options.hide = hide;
                                                      return renderjson; };
            renderjson.set_show_to_level = function(level) { renderjson.options.show_to_level = typeof level == "string" &&
                                                                                            level.toLowerCase() === "all" ? Number.MAX_VALUE
                                                                                                                          : level;
                                                         return renderjson; };
            renderjson.set_max_string_length = function(length) { renderjson.options.max_string_length = typeof length == "string" &&
                                                                                                     length.toLowerCase() === "none" ? Number.MAX_VALUE
                                                                                                                                     : length;
                                                              return renderjson; };
            renderjson.set_sort_objects = function(sort_bool) { renderjson.options.sort_objects = sort_bool;
                                                            return renderjson; };
            renderjson.set_replacer = function(replacer) { renderjson.options.replacer = replacer;
                                                       return renderjson; };
            renderjson.set_collapse_msg = function(collapse_msg) { renderjson.options.collapse_msg = collapse_msg;
                                                               return renderjson; };
            renderjson.set_property_list = function(prop_list) { renderjson.options.property_list = prop_list;
                                                             return renderjson; };
            // Backwards compatiblity. Use set_show_to_level() for new code.
            renderjson.set_show_by_default = function(show) { renderjson.options.show_to_level = show ? Number.MAX_VALUE : 0;
                                                          return renderjson; };
            renderjson.options = {};
            if(useDefaultIcons) {
                renderjson.set_icons('⟱', '⟰')
            } else {
                renderjson.set_icons('⊕', '⊖');
            }
            renderjson.set_show_by_default(false);
            renderjson.set_sort_objects(sortObjects);
            if(maxStringLength === undefined) {
                renderjson.set_max_string_length("none");
            } else {
                renderjson.set_max_string_length(maxStringLength);
            }
            renderjson.set_replacer(void 0);
            renderjson.set_property_list(void 0);
            renderjson.set_collapse_msg(function(len) { return len + " item" + (len==1 ? "" : "s") })
            return renderjson;
    })();

        if (define) define({renderjson:renderjson})
        else (module||{}).exports = (window||{}).renderjson = renderjson;
        renderjson.set_show_to_level("all");
        this.jsonValue = typeof this.jsonValue !== "string"? this.jsonValue : JSON.parse(this.jsonValue);
        //TODO: normalize the json before sending it through here. Convert to an object, then back again.
        this.template.querySelector(".jsonContainer").appendChild(renderjson(this.jsonValue));
        this.jsonString = JSON.stringify(this.jsonValue);  
        this.colorSyntax('.renderjson .syntax', this.syntaxColor);
        this.colorSyntax('.renderjson .string', this.stringColor);
        this.colorSyntax('.renderjson .number', this.numberColor);
        this.colorSyntax('.renderjson .boolean', this.booleanColor);
        this.colorSyntax('.renderjson .key', this.keyColor);
        this.colorSyntax('.renderjson .keyword', this.keywordColor);
    }
    colorSyntax(className, color) {
        let elements = this.template.querySelectorAll(className);
        for (let i = 0; i < elements.length; i++) {
            elements[i].style.color = color;
        }
    }
    isJson(item) {
        item = typeof item !== "string"
            ? JSON.stringify(item)
            : item;

        try {
            item = JSON.parse(item);
        } catch (e) {
            return false;
        }

        if (typeof item === "object" && item !== null) {
            return true;
        }

        return false;
    }
    renderedCallback() {
        if (this.initialRender) {
            this.initialRender = false;
            if(this.isJson(this.jsonValue)) {
                this.renderJson();
            } else {
                try {
                    JSON.parse(this.jsonValue);
                } catch(err) {
                    this.errorMessage = 'Error: Value not parseable json. ' + err.name + ': ' + err.message;
                }
            }
        } 
    }
}