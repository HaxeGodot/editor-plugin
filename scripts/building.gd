tool
class_name Building

extends Control

func build_haxe_project():
	print("Building haxe project...");

	var res = OS.execute("haxe", ["build.hxml"], true);
		
	$ProgressBar.value = 1
	yield(VisualServer, 'frame_post_draw')
	
	print("Project builded with code: ", res)

	queue_free()
