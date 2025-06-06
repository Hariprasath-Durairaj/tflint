resource "azurerm_policy_definition" "require_tags" {
  name         = var.policy_definition_name
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require tags on resources"
  description  = "Ensures that specified tags are set on all resources."
  metadata     = <<METADATA
    {
      "category": "Tags"
    }
METADATA

  parameters = jsonencode({
    tagName = {
      type        = "String"
      metadata = {
        description = "Name of the tag, such as 'Environment'"
        displayName = "Tag Name"
      }
    }
    tagValue = {
      type        = "String"
      metadata = {
        description = "Value of the tag"
        displayName = "Tag Value"
      }
    }
  })

  policy_rule = <<POLICY_RULE
  {
    "if": {
      "field": "[parameters('tagName')]",
      "exists": "false"
    },
    "then": {
      "effect": "modify",
      "details": {
        "roleDefinitionIds": [
          "/providers/microsoft.authorization/roleDefinitions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" // Use built-in Contributor role or customize
        ],
        "operations": [
          {
            "operation": "add",
            "field": "[parameters('tagName')]",
            "value": "[parameters('tagValue')]"
          }
        ]
      }
    }
  }
POLICY_RULE
}

resource "azurerm_policy_assignment" "require_tags" {
  name                 = var.policy_assignment_name
  scope                = var.scope
  policy_definition_id = azurerm_policy_definition.require_tags.id

  parameters = jsonencode({
    tagName  = { value = var.required_tag_name }
    tagValue = { value = var.required_tag_value }
  })
}
