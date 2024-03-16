<h1 align="center">
	☕ treason
</h1>

treason is a work-in-progress external game hack for Among Us written in [Zig](https://ziglang.org) and dependency-free (outside of the Windows C API).

## How to use

1. Install [Zig](https://ziglang.org/download/) on your computer. I used [Scoop](https://scoop.sh) and installed zig-dev from the `versions` bucket.
    1. treason was built using version 0.12.0-dev.3291. Forward compatibility is not guaranteed.
2. Clone the repository and run `zig build`. The build script will automatically link the libc library (msvc).
3. Run `./treason.exe` and launch Among Us.

## Contributing

This is a minimal example of an external game hack written in Zig. As such, care should be taken when contributing to the project to:

- Not introduce external dependencies.
- Maintain the Zig version mentioned above and not introduce issues by breaking the versioning scheme.
- Rely only on the Windows API when the Zig stdlib does not have an equivalent.
- Modify the build script only when necessary.

## License

This project is licensed under the MIT License. Do what you want as long as you abide by the terms of the license.

## Roadmap

[ ] | Long term- feature parity with [CychAU](https://github.com/CychUC/CychAU).
[ ] | Introduce a runtime config file for offsets and patterns using the Zig Object Notation format.