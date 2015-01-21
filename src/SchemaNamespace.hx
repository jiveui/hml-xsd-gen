package ;

import haxe.ds.StringMap;

class SchemaNamespace {

    public var name: String;
    private var dependencies: StringMap<SchemaNamespace> = new StringMap<SchemaNamespace>();
    private var types: Array<SchemaType> = [];

    public static var namespaces: StringMap<SchemaNamespace> = new StringMap<SchemaNamespace>();
    public static function getNamespace(name: String): SchemaNamespace  {
        if (null == name || "" == name) name = "empty";
        if (!namespaces.exists(name)) {
            namespaces.set(name, new SchemaNamespace(name));
        }
        return namespaces.get(name);
    }

    private function new(name: String) {
        if (null == name || "" == name) name = "empty";
        this.name = name;
    }

    public function addType(c: SchemaType) {
        types.push(c);
        if (null != c.getBase() && c.getBase().getNameSpace().name != name) {
            addDependence(c.getBase().getNameSpace());
        }
        for (p in c.getProperties(this)) {
            if (null != p.namespace && p.namespace.name != name) {
                addDependence(p.namespace);
            }
        }
    }

    public function addDependence(d: SchemaNamespace) {
        dependencies.set(d.name, d);
    }


    public function getShemaNamespaceName() {
        return StringTools.replace(name,".","-");
    }

    public function toXmlString(): String {
        var buf: StringBuf = new StringBuf();
        var tempbuf:String = "";

        buf.add('<xs:schema targetNamespace="${name}" xmlns="${name}" xmlns:xs="http://www.w3.org/2001/XMLSchema"\n');
        for(d in dependencies) {
            buf.add('xmlns:${d.getShemaNamespaceName()}="${d.name}"\n');
            tempbuf+='<xs:import namespace="${d.name}" schemaLocation="${d.name}.xsd" />\n';
        }
        buf.add(">\n");
        buf.add(tempbuf);

        for(t in types) {
            buf.add(t.toValueTypeXmlString(this));
            buf.add("\n");
        }

        for(t in types) {
            buf.add(t.toComplexTypeXmlString(this));
            buf.add("\n");
        }

        buf.add("\n");

        for(t in types) {
            buf.add(t.toElementXmlString(this));
        }

        buf.add("</xs:schema>\n");
        return buf.toString();
    }

}
