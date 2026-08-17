# Advanced example

Demonstrates a two-level folder hierarchy (departments -> environment folders)
and projects with inline API enablement. Level-2 folders nest under a level-1
folder by referencing its output ID as `parent`. Replace the organization ID,
project IDs, and billing account with your own values.

```bash
tofu init
tofu plan
tofu apply
```
