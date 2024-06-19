# Ultimate Retro Shader Collection
A compilation of shaders designed to replicate the graphical style of the PlayStation and Nintendo 64 in the Godot engine.

<p align="center">
<img alt="URSC Logo" src="docs/images/logo.png" width="192">
</p>

---

## :clipboard: Overview

Ultimate Retro Shader Collection (**URSC**) is a unification and enhancement of various "retro-3D" shaders sourced from the Godot community. These shaders are essential for creating authentic graphics reminiscent of the *PlayStation* (PSX) or *Nintendo 64* (N64).

If you'd like to get a feel for what the collection has to offer, [a demo project](https://github.com/Zorochase/ultimate-retro-shader-collection-demo) exists, which you can even play right in your browser on [itch.io](https://zorochase.itch.io/ultimate-retro-shader-collection-for-godot)!

When you're ready to integrate URSC into your project, there are a few places you can download it from:
- the [Releases](https://github.com/Zorochase/ultimate-retro-shader-collection/releases) page here on GitHub
- the itch.io page (the same one as the demo, just scroll down)
- the [Godot Asset Library](https://godotengine.org/asset-library/asset/2989)

All of these sources will host the latest version of the collection.

### Features:
- Vertex snapping (a.k.a. *vertex jitter*)
- Affine texture mapping (a.k.a. *texture warping*)
- 3-point texture filtering (as seen on N64)
- Distance-based texture LOD (as seen in some PSX games) (1.2.0+)
- Special "metallic/reflective" and "shiny/glossy" effects
- Customization through a wide range of uniforms and macros
- Screen-reading color reduction with dithering and additive/subtractive fade effects
- Single-image, flat sky (1.2.0+)
- Support for all [rendering methods](https://docs.godotengine.org/en/stable/contributing/development/core_and_modules/internal_rendering_architecture.html#rendering-methods) (`Forward+`, `Mobile`, and `Compatibility`) (1.1.0+)

## :book: Documentation

Check out these articles from the Godot documentation before getting started with URSC:
- [Available 3D Formats](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html)
- [Introduction to Shaders](https://docs.godotengine.org/en/stable/tutorials/shaders/introduction_to_shaders.html)
- [Shader Materials](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_materials.html)
- [Shading Reference](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/index.html)

When you feel comfortable working with shaders in Godot, you can read up on URSC here:
- [Getting Started](docs/getting_started.md)
- [URSC `spatial` Shaders](docs/spatial_shaders.md)
- [URSC `canvas_item` Shaders](docs/canvas_item_shaders.md)
- [Tips and Tricks](docs/tips_and_tricks.md)

## :question::exclamation: Need help? Have an idea?

Please **do not** open an issue unless you've actually found something wrong! If you need help using the shaders, have an idea you want to talk about, or want to show off something you've made with the collection, visit the [Discussions](https://github.com/Zorochase/ultimate-retro-shader-collection/discussions) page!

## :sunglasses: Credits

Of course, this collection would not've been possible without the amazing work done by:

- [MenacingMecha](https://menacingmecha.itch.io/)
  - This collection derives from his [PSX](https://github.com/MenacingMecha/godot-psx-style-demo) and [N64](https://github.com/MenacingMecha/godot-n64-shader-demo) shaders. If you need inspiration for creating your own retro-3D game, definitely have a look at his work!
- [Zacksly](https://zacksly.itch.io/)
  - The "shiny" effect is adapted from their [PSX Pickup Shader](https://zacksly.itch.io/psx-pickup-shader) for Godot 3.
- [tentabrobpy](https://godotshaders.com/author/tentabrobpy/)
  - The "flat sky" effect is adapted from their [N64 Style Skybox](https://godotshaders.com/shader/n64-style-skybox/) shader on Godot Shaders.