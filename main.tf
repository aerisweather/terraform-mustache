# Write the template to a file
locals {
  template_file_path = "${path.module}/__template.mustache"
  rendered_file_path = "${path.module}/__rendered_template"
}
resource "local_file" "template_file" {
  content = "${var.template}"
  filename = "${local.template_file_path}"
}

# Render mustache template from template context
resource "null_resource" "render_mustache" {
  provisioner "local-exec" {
    command = "echo '${jsonencode(var.template_context)}' | mustache - ${local.template_file_path} > ${local.rendered_file_path}"
  }
  triggers {
    # Always render the mustache template
    # The problem is that it will always want to read from the files,
    # even if they're deleted
    # (I can't add triggers to the `local_file` data source)
    # So if I don't re-generate them every time, tf will fail when it tries to read them
    always_run = "${timestamp()}"
  }
}

# Load the rendered file content
data "local_file" "rendered_content" {
  depends_on = ["null_resource.render_mustache"]
  filename = "${local.rendered_file_path}"
}

# Delete the file artifacts
resource "null_resource" "delete_file_artifacts" {
  depends_on = ["data.local_file.rendered_content"]
  provisioner "local-exec" {
    command = "rm -f ${local.template_file_path}; rm -f ${local.rendered_file_path}"
  }
  triggers {
    always_run = "${timestamp()}"
  }
}