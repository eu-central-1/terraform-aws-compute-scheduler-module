Contributing Guidelines
========
We love your input! We want to make contributing to this project as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Proposing new features
- Submitting a fix
- Contribute code

## Bug tracking, problems and features

We currently planning further development in GitHub at https://github.com/eu-central-1/terraform-aws-compute-scheduler-module/issues

## Submitting a fix or contributing code

When contributing to this repository, please open up a GitHub issue first with short description to discuss the change you wish to make.

### General notes

Please get attention to apply global variables of the module, for example `name_prefix`, `create` and `tags`.

## Structure and Naming

### Names

Every name for a variable, resource and module should use [snake_case_naming](https://en.wikipedia.org/wiki/Snake_case) style in lower case.
Avoid any unusual technical abbreviation for names.
Name prefixes can be used for some logical grouping, but you should avoid general prefixes that doesn't provide value for reading and understanding.

### Submodules

Submodules are located in a subfolder under `modules` please use descriptive and short names for your submodule.
Submodules needs to contain folder structure of `docs`, `examples` and `assets` similar to root folder.

### Documentation

Module documentation at `./docs/USAGE.md` is generated automatically.
If you change variables, change outputs or add submodules please generate new file.
`make docs` will do the job for you.

### Examples

If you add parameters or additition extensions, you should add examples for it too.
For a special use case you should add a dedicated folder in examples with descriptive name.
