package ;

import sys.FileSystem;
import haxe.io.Path;
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

        //********************************************************
        // Copied from Lime
        // When the command-line tools are called from haxelib,
        // the last argument is the project directory and the
        // path to NME is the current working directory

        var args = Sys.args ();
        var lastArgument = new Path (args[args.length - 1]).toString ();

        if (((StringTools.endsWith (lastArgument, "/") && lastArgument != "/") || StringTools.endsWith (lastArgument, "\\")) && !StringTools.endsWith (lastArgument, ":\\")) {

            lastArgument = lastArgument.substr (0, lastArgument.length - 1);

        }

        if (FileSystem.exists (lastArgument) && FileSystem.isDirectory (lastArgument)) {
            Sys.setCwd (lastArgument);
            args.pop ();
        }
        //********************************************************


        var xml:Xml = Xml.parse(File.getContent(config.xmlPath)).firstElement();

        new RootObjectType();
        new StandardSchemaType("Int");
        new StandardSchemaType("UInt");
        new StandardSchemaType("Float");
        new StandardSchemaType("Bool");

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
