# SwiftDTO

![Overview](/images/json2swift.jpg)

Generate swift DTO files from CoreData model

A macOS command line tool that generates Swift data models based on one or more CoreData model files in XML format.
Much in the same way as you can generate CoreData classes within Xcode ("Create NSManagedObject subclass...").

Written in Swift 3.

## Features

- Processes XML files, which represent a CoreData model, which was created with Xcodes CoreData editor
- Generates immutable Swift struct definitions
- Converts JSON Date representations to Swift Date objects

## What is code generation?

Using a JSON-to-Swift code generator is very different from using a JSON library API. If you have never worked with a code generator before, check out [this blog post](https://ijoshsmith.com/2016/11/03/swift-json-library-vs-code-generation/) for a quick overview.

## How to get it

- Download the `SwiftDTO` app binary from the latest [release](https://github.com/a7ex/SwiftDTO/release)
- Copy `SwiftDTO` to your desktop
- Open a Terminal window and run this command to give the app permission to execute:

```
chmod +x ~/Desktop/SwiftDTO
```

Or build the tool in Xcode yourself:

- Clone the repository / Download the source code
- Build the project
- Open a Finder window to the executable file

![How to find the executable](/images/show_in_finder.png)

- Drag `SwiftDTO` from the Finder window to your desktop

## How to install it

Assuming that the `SwiftDTO` app is on your desktop…

Open a Terminal window and run this command:
```
cp ~/Desktop/SwiftDTO /usr/local/bin/
```
Verify `SwiftDTO` is in your search path by running this in Terminal:
```
SwiftDTO
```
You should see the tool respond like this:
```
Expected string argument defining the path to the XCModelData file!
Usage: ./SwiftDTO [string]
```
Now that a copy of `SwiftDTO` is in your search path, delete it from your desktop.

You're ready to go! 🎉

## How to use it

Open a Terminal window and pass `SwiftDTO` a file path to a CoreData model XML file:
```
SwiftDTO /path/to/some/CDData.xcdatamodel/contents
```
The tool creates the swift files in the working directory, unless you specify an output folder as the second command line argument.

The source code download includes an `example` directory with a `CDData` CoreData file so that you can test it out.

## Structure and property names

For each entity found in the provided CoreData XML file `SwiftDTO` creates a swift file with either: 
- the corresponding struct for the DTO (Data Transfer Object)
- the corresponding enum type, if the entity is marked as being an enum (User Info for that entity has a key "isEnum" with a value of "1").
- the corresponding protocol, if the entity is an abstract entity




## Date parsing

`SwiftDTO` creates Date objects from strings or timestamps
