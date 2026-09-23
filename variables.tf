variable "name_prefix" {
  type    = string
  default = null

  validation {
    condition     = var.name_prefix == null || can(regex("^[a-z0-9]{3,}$", var.name_prefix))
    error_message = "The name_prefix value must be null or have at least 3 lowercase letters and/or digits"
  }
}

variable "create" {
  description = "Enable resource creation. Use it instead of 'count' at module level"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
