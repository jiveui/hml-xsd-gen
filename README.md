hml-xsd-gen
============

A tool to generate XSD files by the code structure XML compiled by Haxe with '-xml' option

Installation
------------

haxelib git hml-xsd-gen https://github.com/ngrebenshikov/hml-xsd-gen

Usage
-----

haxelib run hml-xsd-gen

 - [-xml | --input-xml-path] <filePath>       : Set the path to input XML file generated during haxe compilation with -xml parameter
 - [-xsd | --output-xsd-folder] <folderPath>    : Set the path to folder where output XSD files should be placed
 - [-explicit | --only-explicit-children] : Add only children explicitly set via a class meta @:children("full.class.name")
