# :rocket: Getting Started

When you're ready to integrate URSC into your project, there are a few places you can download it from:
- the [Releases](https://github.com/Zorochase/ultimate-retro-shader-collection/releases) page here on GitHub
- the [itch.io](https://zorochase.itch.io/ultimate-retro-shader-collection-for-godot) page
- the [Godot Asset Library](https://godotengine.org/asset-library/asset/2989)

> [!IMPORTANT]
> Be sure to download the version of the collection that corresponds to the version of Godot you are using. You'll see the Godot version in the name of the zip file.
>
> For example, in `ursc_1.0.0_4.2.2.zip`:
> - `1.0.0` is the version of the shader collection.
> - `4.2.2` is the version of Godot the shader collection was made with.
>
> So, you should only use URSC `1.0.0` with Godot `4.2.2`. Using different versions may result in broken shaders due to changes or missing features; therefore, they are *not supported!*

After downloading, extract the zip file into your project. The `ursc` folder extracted from the zip will contain the complete collection, including the license.

Next, you'll need to add a few [global uniforms](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shading_language.html#global-uniforms). These uniforms are *mandatory* for the `spatial` shaders to work correctly, regardless of the look you're going for (however, the default values you choose are entirely up to you):

| Name                         | Type    | Default Value |
| ---------------------------- | -----   | ------------- |
| `affine_texture_mapping`     | `bool`  | `true`        |
| `cull_distance`              | `float` | `64`          |
| `texture_filtering`          | `bool`  | `false`       |
| `texture_lod_halve_distance` | `float` | `0`           |
| `vertex_snap_intensity`      | `int`   | `2`           |

You should now be able to use the shaders in your project!
