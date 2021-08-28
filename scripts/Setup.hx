import sys.io.Process;
import haxe.xml.Access;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class Setup {
	public static function main() {
		// Checking haxelib for godot externs.
		final haxelibCheck = new Process("haxelib", ["path", "godot"]);
		if (haxelibCheck.exitCode() != 0) {
			Sys.print("haxelib");
			return;
		}

		// Find unique csproj file.
		var csproj = null;

		for (entry in FileSystem.readDirectory(".")) {
			if (FileSystem.isDirectory(entry)) {
				continue;
			}

			if (entry.endsWith(".csproj")) {
				if (csproj != null) {
					Sys.print("multiple_csproj");
					return;
				}

				csproj = entry;
			}
		}

		if (csproj == null) {
			Sys.print("csproj");
			return;
		}

		// Dirty check.
		final dirty = ["build.hxml", "build/", "scripts/"].filter(entry -> FileSystem.exists(entry));

		if (dirty.length != 0) {
			Sys.print("dirty:" + dirty.join(" "));
			return;
		}

		// Update csproj file.
		final csprojData = new Access(Xml.parse(File.getContent(csproj)));
		final propertyGroup = csprojData.node.Project.node.PropertyGroup;

		for (property in propertyGroup.elements) {
			switch (property.name) {
				case "AllowUnsafeBlocks", "TargetFramework":
					propertyGroup.x.removeChild(property.x);

				default:
			}
		}

		propertyGroup.x.addChild(Xml.parse("<AllowUnsafeBlocks>true</AllowUnsafeBlocks>"));
		propertyGroup.x.addChild(Xml.parse("<TargetFramework>netstandard2.1</TargetFramework>"));

		File.saveContent(csproj, XmlPrinter.print(csprojData.x));

		// Create project.
		FileSystem.createDirectory("scripts");
		File.saveContent("scripts/import.hx", "import godot.*;\nimport godot.GD.*;\n\nusing godot.Utils;\n");
		File.saveContent("build.hxml", "--cs build\n--define net-ver=50\n--define no-compilation\n--define analyzer-optimize\n--class-path scripts\n--library godot\n--macro godot.Godot.buildProject()\n--dce full\n");

		final ret = Sys.command("haxe", ["build.hxml"]);
		if (ret == 0) {
			Sys.print("ok");
		}
	}
}

// Modified version of haxe.xml.Printer
class XmlPrinter {
	static public function print(xml:Xml) {
		final printer = new XmlPrinter();
		printer.writeNode(xml, "");
		return printer.output.toString();
	}

	var output:StringBuf;

	function new() {
		output = new StringBuf();
	}

	function writeNode(value:Xml, indent:String) {
		switch (value.nodeType) {
			case CData:
				write(indent + "<![CDATA[");
				write(value.nodeValue);
				write("]]>");
				newline();
			case Comment:
				var commentContent = value.nodeValue;
				commentContent = ~/[\n\r\t]+/g.replace(commentContent, "");
				commentContent = "<!--" + commentContent + "-->";
				write(indent);
				write(StringTools.trim(commentContent));
				newline();
			case Document:
				for (child in value) {
					writeNode(child, indent);
				}
			case Element:
				write(indent + "<");
				write(value.nodeName);
				for (attribute in value.attributes()) {
					write(" " + attribute + "=\"");
					write(StringTools.htmlEscape(value.get(attribute), true));
					write("\"");
				}
				if (hasChildren(value)) {
					final textOnly = hasTextOnly(value);
					write(">");
					if (!textOnly) {
						newline();
					}
					for (child in value) {
						writeNode(child, textOnly ? "" : (indent + "  "));
					}
					write((textOnly ? "" : indent) + "</");
					write(value.nodeName);
					write(">");
					newline();
				} else {
					write("/>");
					newline();
				}
			case PCData:
				final nodeValue = value.nodeValue.trim();
				if (nodeValue.length != 0) {
					write(indent + StringTools.htmlEscape(nodeValue));
				}
			case ProcessingInstruction:
				write("<?" + value.nodeValue + "?>");
				newline();
			case DocType:
				write("<!DOCTYPE " + value.nodeValue + ">");
				newline();
		}
	}

	inline function write(input:String) {
		output.add(input);
	}

	inline function newline() {
		output.add("\n");
	}

	function hasTextOnly(value:Xml):Bool {
		for (child in value) {
			switch (child.nodeType) {
				case PCData:
				default:
					return false;
			}
		}
		return true;
	}

	function hasChildren(value:Xml):Bool {
		for (child in value) {
			switch (child.nodeType) {
				case Element, PCData:
					return true;
				case CData, Comment:
					if (StringTools.ltrim(child.nodeValue).length != 0) {
						return true;
					}
				case _:
			}
		}
		return false;
	}
}
