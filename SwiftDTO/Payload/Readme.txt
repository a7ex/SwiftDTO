In order to translate the XCModel file with the DTO definitions:
In the terminal change into this directory and execute:

./SwiftDTO -d ../GeneratedDTOs -m swift myDTO.xcdatamodel/contents

That will read in the xml file <2 parameter> and output the generated swift files into the folder <1nd parameter>

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
