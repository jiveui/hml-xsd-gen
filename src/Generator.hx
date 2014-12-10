package ;

import sys.io.File;
import hxargs.Args;

class Generator {
    public static function main() {
        var config: Dynamic = {};

        var argHandler = Args.generate([
            @doc('Set the path to input XML file generated during haxe compilation with -xml parameter')
            ["-xml", "--input-xml-path"] => function(path: String) { config.xmlPath = path; },

            @doc('Set the path to folder where output XSD files should be placed')
            ["-xsd", "---output-xsd-folder"] => function(path: String) { config.xsdPath = path; },
            _ => function(arg: String) { Sys.println("Unknown argument"); }
        ]);

        var args = Sys.args();
        if (args.length == 0) Sys.println(argHandler.getDoc());
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
        }

        for (ns in SchemaNamespace.namespaces) {
            sys.io.File.saveContent(config.xsdPath + "/" + ns.name + ".xsd", ns.toXmlString());
        }
    }
}
