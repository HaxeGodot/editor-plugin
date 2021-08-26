![](https://raw.github.com/HaxeGodot/godot/main/.github/logo.png)

[haxe externs](https://github.com/HaxeGodot/godot) | [editor plugin](https://github.com/HaxeGodot/editor-plugin) | [demo](https://github.com/HaxeGodot/squash-the-creeps-3d) | [api doc](https://haxegodot.github.io/godot/) | [discussions](https://github.com/HaxeGodot/godot/discussions)

# Godot Editor Haxe Support Plugin

Godot 3.3 engine editor plugin to help with Haxe development.

The plugin is still in alpha, open an [issue](https://github.com/HaxeGodot/editor-plugin/issues) for bug reports or feature requests.

## Installation

The plugin isn't yet available on the godot asset library, to install it you can either:

* [download this repository](https://github.com/HaxeGodot/editor-plugin/archive/refs/heads/main.zip) and extract it in the `addons/haxe` folder of your project
  
  You need to remove the `editor-plugin-main` folder added by github: have `addons/haxe/plugin.cfg` not `addons/haxe/editor-plugin-main/plugin.cfg`
* add it as a submodule `git submodule add https://github.com/HaxeGodot/editor-plugin.git addons/haxe`

You need to enable the plugin by going in the Project -> Project Settings menu, Plugins tab, and checking the Enabled box for the Haxe plugin.

## Setup

Haxe support requires Godot C#, if it hasn't been setup click on Project -> Tools -> C# -> Create C# solution.

The plugin can setup by clicking on the Project -> Tools -> Haxe -> Setup menu.

This will check for the presence of the godot haxelib, update the C# solution and add a hxml.
If the project already contains some of these files the setup will be stopped.

You can also do a [manual setup](#manual-setup) if you want more control.

## Haxe scripts

You can add/load/remove a Haxe script on a node by clicking on it, and in the inspector in Node -> Script -> Haxe Script click on the resource box.

When creating or clicking Edit on an script it'll open in your editor. By default it is configured for VSCode, and can be changed in Project -> Project Settings -> Haxe -> External Editor. For now only `None` and `VSCode` are supported.

### Building

You need to build the Haxe code before launching your game, you can do that:

* by manually using the hxml `haxe build.hxml`
* through your editor
* directly in the Godot editor in the bottom tab Haxe -> Build Haxe Project

Note: The files in `scripts/` must all define their main type, for a file `Foo.hx` you must have the type `Foo`, otherwise compilation will fail.

## Manual setup

Example hxml:
```hxml
--cs build
--define net-ver=50
--define no-compilation
--define analyzer-optimize
--class-path scripts
--library godot
--macro godot.Godot.buildProject()
--dce full
```

Modify the `<PropertyGroups>` of the `csproj` file:
```xml
<AllowUnsafeBlocks>true</AllowUnsafeBlocks>
<TargetFramework>netstandard2.1</TargetFramework>
```

## License

The plugin is MIT licensed.
