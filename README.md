# Terraform `mustache` module

Renders [mustache](https://mustache.github.io/) templates within terraform

## Why?

Terraform has a [built in `template` provider](https://www.terraform.io/docs/providers/template/index.html), but [it does not allow using lists](https://github.com/hashicorp/terraform/issues/9368) within the template context.

The mustache module will allow you to render templates with more complex data structures, such as lists.

Note that because of some complexity in passing templates between files and strings, this module will require the creation of new resources on every run, even if there are no changes to the template or context. While this is not ideal, it may be the only option available for this type of behavior.

## Arguments

- `template_context` - (Map) The data to pass to the template  
- `template` - (String) The [mustache template](https://mustache.github.io/mustache.5.html)

## Outputs

- `rendered` - (String) The rendered template

## Example

```hcl-terraform
module "template" {
  source = "github.com/aerisweather/terraform-mustache"
  template_context = {
    items = [
      {
        foo = "bar"
      },
      {
        foo = "baz"
      }
    ]
  }
  template = "${file("/path/to/my/template.mustache")}"
}

# Reference the rendered template elsewhere
locals {
  rendered_template = "${module.template.rendered}"
}
```