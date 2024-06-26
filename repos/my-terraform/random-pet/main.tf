resource "random_pet" "my-pet" {
  prefix = var.prefix
  separator = var.separator
  length = var.length
}