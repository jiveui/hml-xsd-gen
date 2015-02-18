package ;

class StandardSchemaType extends SchemaType {

    private var name: String;

    public function new(name:String) {
        this.name = name;
        super(null);
    }

    public override function getNameSpace(): SchemaNamespace {
        return SchemaNamespace.getNamespace("");
    }

    public override function getBase(): SchemaType { return null; }

    public override function getName(): String { return name; }

    public override function getProperties(namespace: SchemaNamespace): Array<SchemaTypeProperty> { return []; }
}
