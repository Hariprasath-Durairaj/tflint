# Azure Tag Policy Terraform Module

This Terraform module facilitates the creation and assignment of Azure Policy Definitions to enforce tagging standards across your Azure resources. It enables organizations to ensure that resources are consistently tagged, aiding in governance, cost management, and operational efficiency.

## 📁 Module Structure

* `main.tf` – Defines the Azure Policy Definition and its assignment.
* `variables.tf` – Declares input variables for customization.
* `output.tf` – Outputs relevant resource identifiers.
* `versions.tf` – Specifies required Terraform and provider versions.

## 🚀 Usage

```hcl
module "tag_policy" {
  source = "../terraform_modules/terraform-azure-tag-policy"

  policy_name             = "require-tags"
  policy_display_name     = "Require Tags on Resources"
  policy_description      = "Ensures that resources have the required tags."
  required_tags           = ["Environment", "Owner"]
  policy_assignment_scope = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  policy_assignment_name  = "require-tags-assignment"
  tags = {
    Environment = "QA"
    ManagedBy   = "Terraform"
  }
}
```



Replace `source` with the correct relative path to this module in your project.

## 📥 Input Variables

| Name                      | Description                                                                       | Type           | Default | Required |   |
| ------------------------- | --------------------------------------------------------------------------------- | -------------- | ------- | -------- | - |
| `policy_name`             | Name of the Azure Policy Definition                                               | `string`       | n/a     | ✅        |   |
| `policy_display_name`     | Display name for the Azure Policy                                                 | `string`       | n/a     | ✅        |   |
| `policy_description`      | Description of the Azure Policy                                                   | `string`       | n/a     | ✅        |   |
| `required_tags`           | List of tag keys that are required on resources                                   | `list(string)` | n/a     | ✅        |   |
| `policy_assignment_scope` | Scope at which the policy will be assigned (e.g., subscription or resource group) | `string`       | n/a     | ✅        |   |
| `policy_assignment_name`  | Name of the policy assignment                                                     | `string`       | n/a     | ✅        |   |
| `tags`                    | Tags to apply to the policy resources                                             | `map(string)`  | `{}`    | ❌        |   |

## 📤 Outputs

| Output Name            | Description                               |   |
| ---------------------- | ----------------------------------------- | - |
| `policy_definition_id` | ID of the created Azure Policy Definition |   |
| `policy_assignment_id` | ID of the Azure Policy Assignment         |   |

## ✅ Requirements

* Terraform `>= 1.3.0`
* AzureRM Provider `~> 3.100`

## 🛡️ Best Practices

* Define a clear tagging strategy for your organization to ensure consistency.
* Use Azure Policy to enforce tagging rules, preventing the creation of resources without the required tags.
* Combine this module with other governance tools to maintain compliance across your Azure environment

## 📄 License

This module is maintained by the DHDP CloudOps team. Contributions and feedback are welcome.
