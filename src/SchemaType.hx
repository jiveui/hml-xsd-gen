package ;

import SchemaNamespace;
import SchemaNamespace;
import haxe.ds.StringMap;

class SchemaType {

    public static var types: StringMap<SchemaType> = new StringMap<SchemaType>();

    private var xml: Xml;
    private var base: SchemaType;
    private var baseSet: Bool;
    private var implementers: StringMap<SchemaType> = new StringMap<SchemaType>();

    public function new(xml: Xml) {
        this.xml = xml;
        types.set(getName(), this);
    }

    public function getNameSpace(): SchemaNamespace {
        var name = if (null == getName() || "" == getName()) "" else getName().substring(0, getName().lastIndexOf("."));
        return SchemaNamespace.getNamespace(name);
    }

    public function getBase(): SchemaType {
        if (!baseSet) {
            var ee = xml.elementsNamed("extends");
            if (ee.hasNext()) {
                var e: Xml = ee.next();
                base = types.get(e.get("path"));
            } else {
                base = types.get("RootObjectType");
            }
            baseSet = true;
        }
        return base;
    }

    public function isInterface(): Bool {
        return null != xml && xml.get("interface") == "1";
    }

    public function addImplementer(t: SchemaType) {
        implementers.set(t.getName(), t);
        if (getNameSpace() != t.getNameSpace()) {
            getNameSpace().addDependence(t.getNameSpace());
        }
    }

    public function processInterfaces() {
        if (null != xml) {
            for(iface in xml.elementsNamed("implements")) {
                var t = types.get(iface.get("path"));
                if (null != t) {
                    t.addImplementer(this);
                }
            }
        }
    }


    public function getName(): String {
        return xml.get("path");
    }

    public function getComplexTypeName(namespace:SchemaNamespace): String {
        var prefix: String = if (namespace != getNameSpace()) getNameSpace().getShemaNamespaceName()+":" else "";
        return prefix + getName().substr(getName().lastIndexOf(".") + 1) + "SchemaType";
    }
    public function getValueTypeName(namespace:SchemaNamespace): String {
        return getComplexTypeName(namespace) + "Value";
    }

    public function getElementName(namespace:SchemaNamespace): String {
        return getName().substr(getName().lastIndexOf(".") + 1);
    }

    public function getProperties(namespace: SchemaNamespace): Array<SchemaTypeProperty> {
        var result: Array<SchemaTypeProperty> = [];

        if (null != xml) {
            for (c in xml.elements()) {
                var child: Xml = c;
                var isHidden = function(c1: Xml) {
                    for (m in c1.elementsNamed("meta")) {
                        if (m.firstElement().get("n") == ":dox" && m.firstElement().firstElement().firstChild().nodeValue == "hide") return true;
                    }
                    return false;
                }
                var propertyNamespace = null;
                if (child.get("public") == "1" &&
                    child.get("static") != "1" &&
                    child.nodeName != "new" &&
                    (null == child.get("set") || "method" != child.get("set")) &&
                    !isHidden(child)) {
                    var type =
                    if (child.firstElement().nodeName == "x")
                        switch(child.firstElement().get("path")) {
                            case "Int": "xs:int";
                            case "Float": "xs:double";
                            case "Bool": "xs:boolean";
                            case _: "xs:string";
                        }
                    else if (child.firstElement().nodeName == "c") {
                        var t = SchemaType.types.get(child.firstElement().get("path"));
                        if (null != t && t.getName() != "String") {
                            propertyNamespace = t.getNameSpace();
                            t.getValueTypeName(namespace);
                        } else "xs:string";
                    } else {
                        "xs:string";
                    }
                    result.push({ name : child.nodeName, type: type, namespace: propertyNamespace });
                }
            }
        }

        return result;
    }

    private function fillProperties(buf: StringBuf, namespace: SchemaNamespace) {
        for (p in getProperties(namespace)) {
            buf.add('<xs:element name="${p.name}" type="${p.type}"/>\n');
        }

        for (p in getProperties(namespace)) {
            var type = if (StringTools.startsWith(p.type, "xs:")) p.type else "xs:string";
            buf.add('<xs:attribute name="${p.name}" type="${type}"/>\n');
        }
    }

    public function toComplexTypeXmlString(namespace:SchemaNamespace): String {
        var buf: StringBuf = new StringBuf();
        buf.add('<xs:complexType name="${getComplexTypeName(getNameSpace())}">\n');
        if (getBase() != null) {
            buf.add('<xs:complexContent>\n');
            buf.add('<xs:extension base="${getBase().getComplexTypeName(namespace)}">\n');
            fillProperties(buf, namespace);
            buf.add('</xs:extension>\n');
            buf.add('</xs:complexContent>\n');
        } else {
            fillProperties(buf, namespace);
        }
        buf.add('</xs:complexType>\n');
        return buf.toString();
    }

    public function toValueTypeXmlString(namespace:SchemaNamespace): String {
        var buf: StringBuf = new StringBuf();
        buf.add('<xs:complexType name="${getValueTypeName(getNameSpace())}">\n');
        if (isInterface()) {
            buf.add("<xs:choice>\n");
            for (imp in implementers) {
                buf.add('<xs:element name="${imp.getElementName(getNameSpace())}" type="${imp.getComplexTypeName(getNameSpace())}"/>\n');
            }
            buf.add("</xs:choice>\n");
        } else {
            buf.add('<xs:element name="${getElementName(getNameSpace())}" type="${getComplexTypeName(getNameSpace())}"/>');
        }
        buf.add('</xs:complexType>\n');
        return buf.toString();
    }

    public function toElementXmlString(namespace:SchemaNamespace): String {
        return '<xs:element name="${getElementName(getNameSpace())}" type="${getComplexTypeName(getNameSpace())}"/>\n';
    }
}
