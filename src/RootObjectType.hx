package ;
class RootObjectType extends SchemaType {

    public function new() {
        super(null);
    }

    override public function getNameSpace(): SchemaNamespace {
        return SchemaNamespace.getNamespace("");
    }

    override public function getBase(): SchemaType { return null; }

    override public function getName(): String {
        return "RootObjectType";
    }

    override public function toComplexTypeXmlString(namespace:SchemaNamespace): String {
        var buf: StringBuf = new StringBuf();
        buf.add('<xs:complexType name="RootObjectTypeSchemaType">');
        if (!Generator.onlyExplicitChildren) {
            buf.add('<xs:any minOccurs="0"/>');
        }
        buf.add('<xs:attribute name="id" type="xs:int"/>\n</xs:complexType>');
        return buf.toString();
    }

    override public function toElementXmlString(namespace:SchemaNamespace): String {
        return "";
    }
}
