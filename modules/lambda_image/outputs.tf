output "image_uri" {
  value = format("%v@%v", local.ecr_image_name, local.docker_registry_image_id)
  description = "Full Uri for pulling docker image"
}