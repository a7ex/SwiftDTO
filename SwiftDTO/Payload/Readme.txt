In order to translate the XCModel file with the DTO definitions:
In the terminal change into this directory and execute:

./SwiftDTO -d ../GeneratedFiles -m swift myDTO.xcdatamodel/contents

That will read in the xml file <2 parameter> and output the generated swift files into the folder <1nd parameter>

--------------------------------------------
NOTES for CoreData Editor:
The coredata model file does NOT need to be compiled. So make sure it is NOT added to any target.
The file is only required at authortime!

---------------------
The following properties are "meaningful" to this exporter:
All Entities and their respective Attributes and Relationships.
All types for Attributes except "Binary data" (will be added on demand...)

---------------------
The types are mapped to swift types as follows:

"Integer 64", "Integer 32", "Integer 16":   => swift type: Int
"Float, "Double", "Decimal":                => swift type: Double
"Boolean":                                  => swift type: Bool
"Transformable":                            => swift type: [String: AnyObject]
"Date":                                     => swift type: Date
"Binary": not supported - yet
every thing else, including "String":       => swift type: String

---------------------
Other settings, that get respected:

---------------------
For Entities:
"Abstract Entity"   => swift protocol (can be used to map parent-child hierarchies. Make the parent "Abstract" and get a swift protocol.)
"Parent entity"     => parent of the entity (swift: protocol; java: class parent)

There are a few "magic modifiers", which can only be expressed using the "User Info" variables.
(That is "kind of" hardcode)
key: "isEnum", value: anything except "0" => true, otherwise false
    this Entity is an Enum and not a class/struct
key: "isPrimitiveProxy", value: anything except "0" => true, otherwise false
    this Entity is only a proxy to an existing swift type. E.g. String (This is useful for arrays containing swift primitive types)

---------------------
For Attributes:
"Optional"          => optional attribute (can be nil) otherwise init() fails, if no value provided
"Default value"     => default value in case the value would otherwise be nil. Esp. useful for "non-Optional" attributes

There is one "magic modifier", which can only be expressed using the "User Info" variables.
(That is "kind of" hardcode)
key: "jsonPropertyName", value: any String.
    this will use a different name in json, than in the output swift/java files. If properties have different names in JSON
    this is also useful to change the structure from input to output, as we support keypaths.
    E.g. attribute "imageUrlString": String can have a "jsonPropertyName" like: "image.url", which would fetch the key "url" in the object "image", if any
    and assign it to the property "imageUrlString"

--------------------------------------------
NOTES for Enums:
Entities can be enums, if there is a non nil value for "isEnum" in "User Info" variables for that Entity
Enum values will always be all uppercased. Use the "jsonPropertyName" for each attribute, where you want to preserve the case, when exporting back to json.


--------------------------------------------
Conditional parsing:
You can have an array of mixed types, as long as they share the same "parent", which will be converted to a protocol.
The type of the array values will then be the protocol type.
In order to instantiate conditionally, an enum will be used, if the enum will provide Relationships to the Entities it shall create.

As attributes and relationships must always start with a lowercase character and the "connection" between attribute and relationship can only be made by their name
the convention is, that corresponding relationships start with an arbitrary character followed by the name of the attribute.
So if you have two enum cases like: "circle" and "rect", the corresponding relationships would be for example "xCIRCLE" or "rCIRCLE" or whatever you want as prefix,

--------------------------------------------
Parse file references:
if parse output is enabled, then an entity with the exact name "ParseFileReference" will be treated as such.
It will use a PFFile object in its default init(parseData:) initializer and use the "name" and "url" attributes directly from the PFFile object.

in the initializer with a a PFObject init(parseData:) an attribute with the exact name "objectId" will be mapped directly to PFObject.objectId

--------------------------------------------
IMPORTANT NOTE:
This program will NOT change your Xcode project file! It won't remove nor add files to your project.

If you have ADDED a NEW entity:
- generate all files with SwiftDTO (see above)
- in Xcode right click on the folder "GeneratedDTOs" and choose "Add files to <project name>..."
and select the file corresponding to the entity, which you created, and add it to the project.
- Make sure the new file's "Target Membership" is set to ONLY <Target for DTO>!

If you DELETED an existing entity:
- generate all files with SwiftDTO (see above)
- delete the corrsponding class file in Xcode (select "move to trash" in the confirmation dialog)

If you changed the name of an existing entity:
follow the steps above to ADD a new file AND follow the steps to remove the file with the old name


ALTERNATIVE:
If you have made a large number of changes, just move all contents of "GeneratedDTOs" to the trash, from within Xcode, then generate all files with SwiftDTO (see above) and then add all new files again in Xcode (again making SURE, that the new files "Target Membership" are set to ONLY <Target for DTO>!)
