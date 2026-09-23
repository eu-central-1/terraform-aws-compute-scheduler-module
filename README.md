Terraform component module for AWS solution to schedule compute resources
========
This is a Terraform module project.
It will deploy scheduler solution at AWS and and required services.

**Current status:** Prototyping

## How it Works

The repository works as Terraform module located in the root folder.
You can reference it in source parameter in module section of Terraform.
```
module "scheduler" {
  source = "github.com/eu-central-1/terraform-aws-compute-scheduler-module"
}
```
For the sake of simplicity, you can use the provided Makefile for basic testing at Linux and WSL2.

Just execute `make` to see what you can do.

### Dependencies and Prerequisites

- **make**

  Mostly preinstalled, if you use Linux or Windows WSL2

- **Rancher Desktop** https://rancherdesktop.io/

  Recommended, if you work with WSL2 and use make command. Container and Docker CLI is used inside Makefile to avoid local Terraform installation at your first steps

- **Granted** https://www.granted.dev/

  Needed, if you work with make command and recommended if you use different AWS accounts

- **AWS CLI** https://aws.amazon.com/cli/

  Optional, but needed for login to AWS using `make deploy`, `make destroy` or `make env`

- **Terraform** https://developer.hashicorp.com/terraform/install

  Optional, if you just start, but recommended for advanced changes and tasks

## How to start

You can choose to use `make` for quick start. Execute `make` for more help.

Alternatively you can skip it and use Terraform directly like a Pro.
You will find code for testing and quickstart in sub-folder [examples](./examples/)

## How to use

You will find module parameter documentation [here](./docs/USAGE.md)

### Local development

This is developed to support development under WSL and Linux (Ubuntu).
For local testing you will need to have make and docker commands available.

### License

This project is published under MIT [LICENSE](./LICENSE).

### Contribute

Contributions are welcome! Read more [here](./docs/CONTRIBUTING.md)
