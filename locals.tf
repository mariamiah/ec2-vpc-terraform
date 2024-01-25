# centrally manage common variables in config
locals {
    prefix = var.prefix
    common_tags = {
        Project = var.project
        Managed_by = "Terraform"
    }
}