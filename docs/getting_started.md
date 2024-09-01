# :rocket: Getting Started

When you're ready to integrate URSC into your project, there are a few places you can download it from:
- the [Releases](https://github.com/Zorochase/ultimate-retro-shader-collection/releases) page here on GitHub
- the [itch.io](https://zorochase.itch.io/ultimate-retro-shader-collection-for-godot) page
- the [Godot Asset Library](https://godotengine.org/asset-library/asset/2989)

> [!IMPORTANT]
> Be sure to check the release notes for your download to see which Godot version(s) it was tested with. The latest release will always be tested with the latest stable version of Godot.

After downloading, extract the zip file into your project. The `ursc` folder extracted from the zip will contain the complete collection, including the license.

Next, you'll need to set up the following [global uniforms](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shading_language.html#global-uniforms). These uniforms are *mandatory* for the shaders to work correctly, regardless of the look you're going for (though their default values are entirely up to you).

For quick setup, run the `setup.gd` script included in the zip file (1.2.0+). You can also plug these values in manually.

| Name                         | Type    | Default Value | Necessary If Using |
| ---------------------------- | -----   | ------------- | ------------------ |
| `affine_texture_mapping`     | `bool`  | `true`        | v1.0.0+            |
| `cull_distance`              | `float` | `64`          | v1.0.0+            |
| `fog_color`                  | `color` | `black`       | v1.3.0+            |
| `fog_start_distance`         | `color` | `0`           | v1.3.0+            |
| `fog_end_distance`           | `color` | `0`           | v1.3.0+            |
| `texture_filtering`          | `bool`  | `false`       | v1.0.0+            |
| `texture_lod_halve_distance` | `float` | `0`           | v1.2.0+            |
| `vertex_snap_intensity`      | `int`   | `2`           | v1.0.0+            |

You should now be able to use the shaders in your project!
