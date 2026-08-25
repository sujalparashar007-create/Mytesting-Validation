# Org Policies Validation Guide

## Scope: Folder Level (278994416390)

All 10 policies are applied at folder level and validated on GCP Console.

---

## Policy 1: `iam.disableServiceAccountKeyCreation`

### Part 1: Validate Existing Resource (Confirm Policy Applied)

**Step 1: Go to GCP Console**
1. Open: https://console.cloud.google.com
2. Select your organization: `563019909339`
3. Navigate to: **IAM & Admin** ? **Organization Policies**
4. In the filter box, select **"Folder"** and enter: `278994416390`

**Step 2: Find the policy**
1. In the search box, type: `iam.disableServiceAccountKeyCreation`
2. Click on the policy name
3. Verify:
   - **Status:** Enforced
   - **Value:** TRUE
   - **Scope:** folders/278994416390

---

### Part 2: Test the Policy (Verify Enforcement)

**Step 1: Go to Service Accounts**
1. Navigate to: **IAM & Admin** ? **Service Accounts**
2. Select project: `test-project-506110`
3. Find: `test-cross-project-sa@test-project-506110.iam.gserviceaccount.com`

**Step 2: Try to create a key**
1. Click on the service account
2. Go to **"Keys"** tab
3. Click **"Add Key"** ? **"Create new key"**
4. Select **"JSON"** format
5. Click **"Create"**

**Expected Result:** Error message — "Key creation is disabled by organization policy" or similar policy violation error.

---

## Policy 2: `iam.restrictCrossProjectServiceAccountLienRemoval`

### Part 1: Validate Existing Resource (Confirm Policy Applied)

**Step 1: Go to GCP Console**
1. Open: https://console.cloud.google.com
2. Select your organization: `563019909339`
3. Navigate to: **IAM & Admin** ? **Organization Policies**
4. In the filter box, select **"Folder"** and enter: `278994416390`

**Step 2: Find the policy**
1. In the search box, type: `iam.restrictCrossProjectServiceAccountLienRemoval`
2. Click on the policy name
3. Verify:
   - **Status:** Enforced
   - **Value:** TRUE
   - **Scope:** folders/278994416390

---

### Part 2: Test the Policy (Verify Enforcement)

**Step 1: Go to Liens page**
1. Navigate to: **IAM & Admin** ? **Liens**
2. Select project: `test-project-506110`

**Step 2: Try to create a lien**
1. Click **"Create Lien"**
2. Select restriction type: `resourcemanager.projects.delete`
3. Add a reason (e.g., "Test lien")
4. Click **"Create"**

**Expected Result:** The lien creation should be restricted or the option to remove liens created by cross-project service accounts should be blocked.

**Note:** This policy prevents service accounts from other projects from removing resource liens. It'''s a protective measure to ensure that critical resources cannot be deleted by unauthorized cross-project service accounts.

---

## Policy 3: `compute.skipDefaultNetworkCreation`

### Part 1: Validate Existing Resource (Confirm Policy Applied)

**Step 1: Go to GCP Console**
1. Open: https://console.cloud.google.com
2. Select your organization: `563019909339`
3. Navigate to: **IAM & Admin** ? **Organization Policies**
4. In the filter box, select **"Folder"** and enter: `278994416390`

**Step 2: Find the policy**
1. In the search box, type: `compute.skipDefaultNetworkCreation`
2. Click on the policy name
3. Verify:
   - **Status:** Enforced
   - **Value:** TRUE
   - **Scope:** folders/278994416390

---

### Part 2: Test the Policy (Verify Enforcement)

**Step 1: Go to VPC Networks**
1. Navigate to: **VPC network** ? **VPC networks**
2. Select project: `test-project-506110`

**Step 2: Check for default network**
1. Look for a network named **"default"**
2. If no default network exists, the policy is working

**Step 3: Try to create a new project (if possible)**
1. Navigate to: **IAM & Admin** ? **Create a Project**
2. Create a new project under folder `278994416390`
3. After creation, go to **VPC network** ? **VPC networks**
4. Verify: No default network is automatically created

**Expected Result:** No default VPC network is created when a new project is created under this folder.

---

## Policy 4: `compute.managed.vmExternalIpAccess`

### Part 1: Validate Existing Resource (Confirm Policy Applied)

**Step 1: Go to GCP Console**
1. Open: https://console.cloud.google.com
2. Select your organization: `563019909339`
3. Navigate to: **IAM & Admin** ? **Organization Policies**
4. In the filter box, select **"Folder"** and enter: `278994416390`

**Step 2: Find the policy**
1. In the search box, type: `compute.vmExternalIpAccess`
2. Click on the policy name
3. Verify:
   - **Status:** Enforced
   - **Value:** All VMs denied external IP access
   - **Scope:** folders/278994416390

---

### Part 2: Test the Policy (Verify Enforcement)

**Step 1: Go to VM Instances**
1. Navigate to: **Compute Engine** ? **VM instances**
2. Select project: `test-project-506110`

**Step 2: Try to create a VM with external IP**
1. Click **"Create Instance"**
2. Fill in:
   - **Name:** `test-external-ip-vm`
   - **Region:** `us-central1`
   - **Zone:** `us-central1-a`
   - **Machine type:** `e2-micro`
3. Go to **"Networking"** section
4. Under **"Network interface"**, try to set **"External IP"** to **"Ephemeral"**
5. Click **"Create"**

**Expected Result:** Error message — "Policy constraints/compute.vmExternalIpAccess violated" or similar policy violation error.

---

## Policy 5: `gcp.restrictServiceUsage`

### Part 1: Validate Existing Resource (Confirm Policy Applied)

**Step 1: Go to GCP Console**
1. Open: https://console.cloud.google.com
2. Select your organization: `563019909339`
3. Navigate to: **IAM & Admin** ? **Organization Policies**
4. In the filter box, select **"Folder"** and enter: `278994416390`

**Step 2: Find the policy**
1. In the search box, type: `gcp.restrictServiceUsage`
2. Click on the policy name
3. Verify:
   - **Status:** Enforced
   - **Value:** Allowed services list (compute.googleapis.com, storage.googleapis.com, cloudkms.googleapis.com)
   - **Scope:** folders/278994416390

---

### Part 2: Test the Policy (Verify Enforcement)

**Step 1: Go to API Library**
1. Navigate to: **APIs & Services** ? **Library**
2. Select project: `test-project-506110`

**Step 2: Try to enable a restricted API**
1. Search for an API that is NOT in the allowed list (e.g., `Cloud Functions API`, `BigQuery API`, `Pub/Sub API`)
2. Click on the API
3. Click **"Enable"**

**Expected Result:** Error message — "Policy constraints/gcp.restrictServiceUsage violated" or similar policy violation error.

**Step 3: Verify allowed APIs work**
1. Search for an API that IS in the allowed list (e.g., `Compute Engine API`, `Cloud Storage API`, `Cloud KMS API`)
2. Click on the API
3. Verify: It should be enabled or allow enabling without error.

---

## Policy 6: `storage.uniformBucketLevelAccess`

### Part 1: Validate Existing Resource (Confirm Policy Applied)

**Step 1: Go to GCP Console**
1. Open: https://console.cloud.google.com
2. Select your organization: `563019909339`
3. Navigate to: **IAM & Admin** ? **Organization Policies**
4. In the filter box, select **"Folder"** and enter: `278994416390`

**Step 2: Find the policy**
1. In the search box, type: `storage.uniformBucketLevelAccess`
2. Click on the policy name
3. Verify:
   - **Status:** Enforced
   - **Value:** TRUE
   - **Scope:** folders/278994416390

---

### Part 2: Test the Policy (Verify Enforcement)

**Step 1: Go to Cloud Storage**
1. Navigate to: **Cloud Storage** ? **Buckets**
2. Select project: `test-project-506110`

**Step 2: Try to create a bucket without uniform access**
1. Click **"Create Bucket"**
2. Fill in:
   - **Name:** `test-uniform-access-bucket`
   - **Region:** `us-central1`
3. Go to **"Permissions"** section
4. Try to disable **"Uniform bucket-level access"**
5. Click **"Create"**

**Expected Result:** Error message — "Policy constraints/storage.uniformBucketLevelAccess violated" or the option to disable uniform access should be grayed out/unavailable.

**Step 3: Verify uniform access is enforced**
1. Create a bucket with uniform access enabled (default)
2. Go to the bucket ? **"Permissions"** tab
3. Verify: **"Uniform bucket-level access"** is enabled and cannot be disabled.

---

## Policy 7: `gcp.restrictNonCmekServices`

### Part 1: Validate Existing Resource (Confirm Policy Applied)

**Step 1: Go to GCP Console**
1. Open: https://console.cloud.google.com
2. Select your organization: `563019909339`
3. Navigate to: **IAM & Admin** ? **Organization Policies**
4. In the filter box, select **"Folder"** and enter: `278994416390`

**Step 2: Find the policy**
1. In the search box, type: `gcp.restrictNonCmekServices`
2. Click on the policy name
3. Verify:
   - **Status:** Enforced
   - **Value:** Allowed services list (compute.googleapis.com, storage.googleapis.com)
   - **Scope:** folders/278994416390

---

### Part 2: Test the Policy (Verify Enforcement)

**Step 1: Go to Compute Engine**
1. Navigate to: **Compute Engine** ? **Disks**
2. Select project: `test-project-506110`

**Step 2: Verify CMEK-encrypted disk exists**
1. Look for disk: `test-ok-cmek`
2. Click on the disk
3. Verify:
   - **Encryption type:** Customer-managed encryption key
   - **KMS Key:** `projects/test-project-506110/locations/us-central1/keyRings/my-keyring/cryptoKeys/my-disk-key`

**Step 3: Try to create a disk without CMEK**
1. Click **"Create Disk"**
2. Fill in:
   - **Name:** `test-no-cmek-disk`
   - **Region:** `us-central1`
   - **Zone:** `us-central1-a`
3. Under **"Encryption"**, select **"Google-managed encryption key"** (default)
4. Click **"Create"**

**Expected Result:** Error message — "Policy constraints/gcp.restrictNonCmekServices violated" or similar policy violation error.

---

## Policy 8: `compute.disableNonFIPSMachineTypes`

### Part 1: Validate Existing Resource (Confirm Policy Applied)

**Step 1: Go to GCP Console**
1. Open: https://console.cloud.google.com
2. Select your organization: `563019909339`
3. Navigate to: **IAM & Admin** ? **Organization Policies**
4. In the filter box, select **"Folder"** and enter: `278994416390`

**Step 2: Find the policy**
1. In the search box, type: `compute.disableNonFIPSMachineTypes`
2. Click on the policy name
3. Verify:
   - **Status:** Enforced
   - **Value:** TRUE
   - **Scope:** folders/278994416390

---

### Part 2: Test the Policy (Verify Enforcement)

**Step 1: Go to VM Instances**
1. Navigate to: **Compute Engine** ? **VM instances**
2. Select project: `test-project-506110`

**Step 2: Try to create a VM with non-FIPS machine type**
1. Click **"Create Instance"**
2. Fill in:
   - **Name:** `test-non-fips-vm`
   - **Region:** `us-central1`
   - **Zone:** `us-central1-a`
3. Under **"Machine type"**, select a non-FIPS machine type (e.g., `e2-micro`, `e2-small`, `n1-standard-1`)
4. Click **"Create"**

**Expected Result:** Error message — "Policy constraints/compute.disableNonFIPSMachineTypes violated" or similar policy violation error.

**Step 3: Verify FIPS machine types work**
1. Try to create a VM with a FIPS-compliant machine type (e.g., `n2-standard-2`, `c2-standard-4`)
2. Verify: VM creation should succeed without error.

---

## Policy 9: `custom.restrictDiskTypes` (Custom Constraint)

### Part 1: Validate Existing Resource (Confirm Policy Applied)

**Step 1: Go to GCP Console**
1. Open: https://console.cloud.google.com
2. Select your organization: `563019909339`
3. Navigate to: **IAM & Admin** ? **Organization Policies**
4. In the filter box, select **"Folder"** and enter: `278994416390`

**Step 2: Find the custom constraint**
1. In the search box, type: `custom.restrictDiskTypes`
2. Click on the constraint name
3. Verify:
   - **Status:** Enforced
   - **Value:** TRUE
   - **Scope:** folders/278994416390

**Step 3: Check custom constraint definition**
1. Navigate to: **IAM & Admin** ? **Organization Policies** ? **Custom Constraints**
2. Search for: `custom.restrictDiskTypes`
3. Verify:
   - **Resource type:** `compute.googleapis.com/Disk`
   - **Method types:** CREATE
   - **Condition:** `resource.type != '''pd-standard''' && resource.type != '''pd-balanced'''`
   - **Action:** DENY

---

### Part 2: Test the Policy (Verify Enforcement)

**Step 1: Go to Compute Engine**
1. Navigate to: **Compute Engine** ? **Disks**
2. Select project: `test-project-506110`

**Step 2: Try to create a disk with restricted type**
1. Click **"Create Disk"**
2. Fill in:
   - **Name:** `test-restricted-disk`
   - **Region:** `us-central1`
   - **Zone:** `us-central1-a`
   - **Encryption:** Customer-managed key (CMEK)
3. Under **"Disk type"**, select a restricted type (e.g., `pd-ssd`, `pd-extreme`)
4. Click **"Create"**

**Expected Result:** Error message — "Policy constraints/custom.restrictDiskTypes violated" or similar policy violation error.

**Step 3: Verify allowed disk types work**
1. Try to create a disk with an allowed type (`pd-standard` or `pd-balanced`)
2. Verify: Disk creation should succeed without error.

---

## Policy 10: `cloudfunctions.allowedVpcConnectorEgressSettings`

### Part 1: Validate Existing Resource (Confirm Policy Applied)

**Step 1: Go to GCP Console**
1. Open: https://console.cloud.google.com
2. Select your organization: `563019909339`
3. Navigate to: **IAM & Admin** ? **Organization Policies**
4. In the filter box, select **"Folder"** and enter: `278994416390`

**Step 2: Find the policy**
1. In the search box, type: `cloudfunctions.allowedVpcConnectorEgressSettings`
2. Click on the policy name
3. Verify:
   - **Status:** Enforced
   - **Value:** Allowed values list (PRIVATE_RANGES_ONLY, ALL_TRAFFIC)
   - **Scope:** folders/278994416390

---

### Part 2: Test the Policy (Verify Enforcement)

**Step 1: Go to Cloud Functions**
1. Navigate to: **Cloud Functions**
2. Select project: `test-project-506110`

**Step 2: Try to create a function with restricted egress setting**
1. Click **"Create Function"**
2. Fill in basic details:
   - **Function name:** `test-egress-function`
   - **Region:** `us-central1`
3. Go to **"Runtime, build, connections and security settings"**
4. Under **"Connections"**, try to set **"Egress setting"** to a value NOT in the allowed list
5. Click **"Create"**

**Expected Result:** Error message — "Policy constraints/cloudfunctions.allowedVpcConnectorEgressSettings violated" or the restricted option should not be available.

**Step 3: Verify allowed egress settings work**
1. Try to create a function with an allowed egress setting (`PRIVATE_RANGES_ONLY` or `ALL_TRAFFIC`)
2. Verify: Function creation should succeed without error.

---

## Validation Summary

| Policy | Constraint | Status | Scope |
|--------|------------|--------|-------|
| 1 | `iam.disableServiceAccountKeyCreation` | ? Validated | Folder |
| 2 | `iam.restrictCrossProjectServiceAccountLienRemoval` | ? Validated | Folder |
| 3 | `compute.skipDefaultNetworkCreation` | ? Validated | Folder |
| 4 | `compute.managed.vmExternalIpAccess` | ? Validated | Folder |
| 5 | `gcp.restrictServiceUsage` | ? Validated | Folder |
| 6 | `storage.uniformBucketLevelAccess` | ? Validated | Folder |
| 7 | `gcp.restrictNonCmekServices` | ? Validated | Folder |
| 8 | `compute.disableNonFIPSMachineTypes` | ? Validated | Folder |
| 9 | `custom.restrictDiskTypes` | ? Validated | Folder |
| 10 | `cloudfunctions.allowedVpcConnectorEgressSettings` | ? Validated | Folder |

**All 10 policies validated at folder level (278994416390)!** ?
