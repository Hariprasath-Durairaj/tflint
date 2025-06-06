# DHDP QA Environment – Terraform Infrastructure

This directory contains the Terraform configuration for provisioning the **Quality Assurance (QA)** environment for the **DHDP** in Microsoft Azure.

---

## 📁 Directory Contents

```

env/QA/
├── backend.tf               # Remote state backend configuration
├── main.tf                  # Root Terraform config for QA environment
├── variables.tf             # Input variables
├── outputs.tf               # Output values
├── terraform.tfvars         # Environment-specific variable values
└── version.tf               # Terraform and provider versions

````

---

## 🔧 Infrastructure Provisioned

This QA environment leverages modules from `../terraform_modules/` to deploy:

- **AKS Cluster**
  - Multiple node pools (Bitnobi, Keycloak, CanDIG, Integrate.ai, WebApp)
  - RBAC, autoscaling, and monitoring enabled
- **Virtual Network**
  - Custom subnets for AKS, VMs, and Bastion
- **Application Gateway + WAF**
  - Custom routing rules and OWASP-based WAF policies
- **Private DNS Zones**
  - Internal name resolution across peered VNets
- **VNet Peering**
  - Peering between shared hub and spoke VNets
- **Bastion Host**
  - Secure access to private VMs
- **Public IPs, NSGs, and VPN Gateways**
- **Key Vault**
  - Stores secrets used during provisioning
- **Backup and Recovery**
  - Recovery Services Vault integration

---

## 🧱 Module Usage

The following modules are called from `main.tf`:

- `terraform-azure-aks`
- `terraform-azure-vnet`
- `terraform-azure-private-dns`
- `terraform-azure-vnet-peering`
- `terraform-azure-waf`
- `terraform-azure-bastion`
- `terraform-azure-keyvault`
- `terraform-azure-public-ip`
- `terraform-azure-tag-policy`

---

## ⚙️ How to Use

### 1. Set Up Backend Storage

Ensure the backend defined in `backend.tf` exists (e.g., Azure Storage Account container for state):

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "dhdp-lab-resource-group"
    storage_account_name = "dhdplabsa"
    container_name       = "tfstate"
    key                  = "qa.terraform.tfstate"
  }
}
````

### 2. Initialize Terraform

```bash
cd env/QA
terraform init
```

### 3. Review Planned Changes

```bash
terraform plan -var-file=terraform.tfvars
```

### 4. Apply Changes

```bash
terraform apply -var-file=terraform.tfvars
```

---

## 🔐 Security Notes

* NSG rules restrict subnet access to internal IP ranges.
* WAF policies protect the App Gateway endpoints.
* VPN Gateway and Bastion are used for private management access.
* Secrets such as ACR pull credentials are managed via Key Vault.

---

## 📌 Environment Tags

Each resource is tagged for cost management and auditing:

* `Environment = QA`
* `Business_Unit = corp`
* `ManagedBy = hello@dhdp-tfri`
* `Purpose = testing-and-experimentation`

---

## ✅ Prerequisites

* Terraform v1.3+
* Azure CLI logged in
* Access to required Azure subscription
* A properly configured remote backend
