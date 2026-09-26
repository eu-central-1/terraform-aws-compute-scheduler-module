Python Lambda for database initialization
=========

This is a Python project, that delivers a scheduler application to stop and startcompute resources in AWS.

## How it Works

This project is built using modern tool for project control called hatch.
You only need to execute hatch to handle build, test and release.
Please read the manual: https://hatch.pypa.io/latest/

### Dependencies and Prerequisites

- **Python3** https://www.python.org/downloads/

- **hatch** [see below](#how-to-start)

## How to Start

* For Linux you can install it by executing
`python3 -m pip install hatch`
* At Windows open cmd as an Administrator and execute
`python3.exe -m pip install hatch`

To create virtual environment with all dependencies run
`hatch shell`

Now, you are ready to code now. If you use VS Code try `code .` command.

## How to Use

This Python Lambda Application will be deployed with the surrounding Terraform module to AWS.
Before any deployment you can run local tests of the code with `hatch test`.