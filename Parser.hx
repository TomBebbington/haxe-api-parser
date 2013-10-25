using sys.io.File;
import haxe.xml.Fast;
using StringTools;
using EReg;
class Parser {
	static inline var PATH = "downloads/api.xml";
	static inline var TAB = "\t".code;
	static inline var NEWLINE = "\n".code;
	static inline var TYPE = "A".code;
	static var MARKDOWN_FILTER =  ~/\n\*?[\t ]+/;
	var buf:StringBuf;
	function new(x:Xml) {
		buf = new StringBuf();
		for(type in x.elements()) {
			printType(type);
			for(field in type.elements())
				if(field.nodeName != "haxe_doc")
					printField(field, type.get("path"), type.nodeName == "enum");
		}
		var encBuf = haxe.Utf8.encode(buf.toString());
		sys.io.File.saveContent("output.txt", encBuf);
	}
	function printType(type:Xml) {
		var doc = type.elementsNamed("haxe_doc").next();
		if(doc != null)
			doc = doc.firstChild();
		var docText = doc == null ? "" : doc.nodeValue;
		if(docText.length == 0)
			return;
		buf.add(type.get("path"));
		buf.addChar(TAB);
		buf.addChar(TYPE);
		buf.addChar(TAB);
		buf.addChar(TAB);
		buf.addChar(TAB);
		buf.addChar(TAB);
		buf.addChar(TAB);
		buf.addChar(TAB);
		buf.addChar(TAB);
		buf.addChar(TAB);
		buf.addChar(TAB);
		buf.addChar(TAB);
		docText = MARKDOWN_FILTER.replace(docText, "\n");
		buf.add(Markdown.markdownToHtml(docText));
		buf.addChar(NEWLINE);
	}
	function printField(field:Xml, path:String, inEnum:Bool) {
		var accessors = "";
		if(field.exists("public") && field.get("public") == "1")
			accessors += "public ";
		else
			accessors += "private ";
		if(field.exists("static") && field.get("static") == "1")
			accessors += "static ";
		var x_s = field.elementsNamed("x"), f_s = field.elementsNamed("f"), c_s = field.elementsNamed("c");
		var code:String = inEnum ? field.nodeName : accessors + if(x_s.hasNext())
			'var ${field.nodeName}:${resolvePath(x_s.next())};';
		else if(f_s.hasNext()) {
			var f:Xml = f_s.next();
			var fcs:Array<String> = [for(e in f.elements()) resolvePath(e)];
			var args:Array<String> = [for(s in f.get("a").split(":")) if(s.length > 0) s];
			var argsStr = [for(i in 0...args.length) '${args[i]}:${fcs[i]}'].join(", ");
			var ret = fcs.pop();
			'function ${field.nodeName}($argsStr):$ret;';
		} else if(c_s.hasNext()) {
			'var ${field.nodeName}:${resolvePath(c_s.next())};';
		} else
			return;
		var doc = field.elementsNamed("haxe_doc").next();
		if(doc != null)
			doc = doc.firstChild();
		var docText = doc == null ? "" : doc.nodeValue;
		buf.add(path + "." + field.nodeName);
		buf.addChar(TAB);
		buf.addChar(TYPE);
		buf.addChar(TAB);
		buf.addChar(TAB);
		buf.addChar(TAB);
		buf.addChar(TAB);
		buf.addChar(TAB);
		buf.addChar(TAB);
		buf.addChar(TAB);
		buf.addChar(TAB);
		buf.addChar(TAB);
		buf.addChar(TAB);
		buf.add("<pre>");
		buf.add(code.htmlEscape());
		buf.add("</pre>");
		docText = MARKDOWN_FILTER.replace(docText, "\n");
		buf.add(Markdown.markdownToHtml(docText));
		buf.addChar(NEWLINE);
	}
	static function resolvePath(x:Xml):String {
		return switch(x.nodeName) {
			case "t": x.get("path") + "<" + [for(e in x.elements()) resolvePath(e)].join(", ") + ">";
			default: x.get("path");
		}
	}
	static function main() {
		new Parser(Xml.parse(PATH.getContent()).firstElement());
	}
}