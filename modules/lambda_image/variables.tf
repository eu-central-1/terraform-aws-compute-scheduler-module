variable "name_prefix" {
  description = "The name prefix of the lambda image build"
   type = string
   nullable = false
}

variable "create" {
  description = "Enable resource creation. Use it instead of 'count' at module level"
  type        = bool
  default     = true
}

variable "platform" {
   description = "Processor architecture platform"
   type = string
   nullable = false
}

variable "docker_file_path" {
   description = "Path of the Dockerfile"
   type = string
   nullable = false
}

variable "project_source_path" {
   description = "Path of the python project files"
   type = string
   nullable = false
}

variable "docker_source_include" {
  description = "List of paths that will be included in the docker image"
  type        = list(string)
  default = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}