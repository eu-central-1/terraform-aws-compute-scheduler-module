variable "name_prefix" {
  description = "The name prefix of the lambda function"
  type        = string
  nullable    = false
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