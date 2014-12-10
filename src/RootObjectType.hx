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
        return '<xs:complexType name="RootObjectTypeSchemaType">
                <xs:any minOccurs="0"/>
                <xs:attribute name="id" type="xs:int"/>
            </xs:complexType>';
    }

    override public function toElementXmlString(namespace:SchemaNamespace): String {
        return "";
    }
}
