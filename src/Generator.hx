package ;

import sys.io.File;
import hxargs.Args;

class Generator {

    public static var onlyExplicitChildren(default, null): Bool;

    public static function main() {
        var config: Dynamic = {};

        var argHandler = Args.generate([
            @doc('Set the path to input XML file generated during haxe compilation with -xml parameter')
            ["-xml", "--input-xml-path"] => function(filePath: String) { config.xmlPath = filePath; },

            @doc('Set the path to folder where output XSD files should be placed')
            ["-xsd", "--output-xsd-folder"] => function(folderPath: String) { config.xsdPath = folderPath; },

            @doc('Add only children explicitly set via a class meta @:children("full.class.name")')
            ["-explicit", "--only-explicit-children"] => function() { onlyExplicitChildren = true; },

            _ => function(arg: String) { /*Sys.println("Unknown argument");*/ }
        ]);

        var args = Sys.args();
        if (args.length <= 1) {
            Sys.println(argHandler.getDoc());
        }
        else {
            argHandler.parse(args);
            new Generator().generate(config);
        }
    }

    public function new() {}

    public function generate(config: Dynamic) {
        var xml:Xml = Xml.parse(File.getContent(config.xmlPath)).firstElement();

        new RootObjectType();

        for(c in xml.elementsNamed("class")) {
            var cl = new SchemaType(c);
        }

        // Link to namespaces and to base classes
        for (c in SchemaType.types) {
            c.getNameSpace().addType(c);
            c.processBaseClass();
            c.processInterfaces();
        }

        for (ns in SchemaNamespace.namespaces) {
            sys.io.File.saveContent(config.xsdPath + "/" + ns.name + ".xsd", ns.toXmlString());
        }
    }
}
