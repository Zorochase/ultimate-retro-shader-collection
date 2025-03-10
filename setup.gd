# Ultimate Retro Shader Collection (v1.4.0): Setup Script
#
# This script will add the necessary shader globals for URSC shaders to your project.godot file.
# To run, just click File -> Run.
# In order to fully register the globals, the editor will be restarted upon running.
#
# NOTE: this script CAN'T be used to manage the globals for your game! You'll need to write your
# own code to handle the values of the globals at runtime.
@tool
extends EditorScript


var shader_globals := {
	"affine_texture_mapping": {
		"type": "bool",
		"value": true
	},
	"fog_color": {
		"type": "color",
		"value": Color(0, 0, 0, 1)
	},
	"fog_start_distance": {
		"type": "float",
		"value": 0.0
	},
	"fog_end_distance": {
		"type": "float",
		"value": 0.0
	},
	"cull_distance": {
		"type": "float",
		"value": 64.0
	},
	"texture_filtering": {
		"type": "bool",
		"value": false
	},
	"texture_lod_halve_distance": {
		"type": "float",
		"value": 0.0
	},
	"vertex_snap_intensity": {
		"type": "int",
		"value": 2
	}
}


func _run() -> void:
	for key: String in shader_globals:
		var full_key := "shader_globals/%s" % key

		if not ProjectSettings.has_setting(full_key):
			ProjectSettings.set_setting(full_key, shader_globals[key])

	ProjectSettings.save()
	EditorInterface.restart_editor()
