**# Basic example**

Calls `resource-hierarchy` to create two top-level folders (Production and

Non-Production), one project in each folder, and enable selected APIs.

**## Usage**

\`\`\`bash

terraform init

terraform plan \\

  -var="org\_id=\<your-organization-id>" \\

  -var="billing\_account=\<your-billing-account-id>"

terraform apply \\

  -var="org\_id=\<your-organization-id>" \\

  -var="billing\_account=\<your-billing-account-id>"

\`\`\`

**## Inputs**

| Name | Description | Type | Required |

|---|---|---|---|

| org\_id | Organization ID under which the top-level folders are created, e.g. `organizations/1234567890`. | \`string\` | yes |

| billing\_account | Billing account ID used to link the example projects. | \`string\` | yes |

**## Outputs**

| Name | Description |

|---|---|

| folder\_ids | Map of folder key to created folder ID. |

| project\_ids | Map of project key to created project ID. |