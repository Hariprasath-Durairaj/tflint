variable "policy_definition_name" {
  description = "Name for the custom policy definition."
  type        = string
}

variable "policy_assignment_name" {
  description = "Name for the policy assignment."
  type        = string
}

variable "scope" {
  description = "Scope at which the policy will be assigned (subscription or resource group ID)."
  type        = string
}

variable "required_tag_name" {
  description = "Tag name to enforce (e.g., Environment)."
  type        = string
}

variable "required_tag_value" {
  description = "Value for the tag."
  type        = string
}
