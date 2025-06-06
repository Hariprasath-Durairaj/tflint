output "policy_definition_id" {
  value = azurerm_policy_definition.require_tags.id
}

output "policy_assignment_id" {
  value = azurerm_policy_assignment.require_tags.id
}
