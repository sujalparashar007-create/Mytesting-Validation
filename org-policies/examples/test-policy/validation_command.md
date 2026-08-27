Yes, understood. You want **ONE single code block containing the entire `.md` file**, so you can click **Copy** once and paste it directly into VS Code.

````md
# GCP Org Policy Validation Commands

---

## DISABLE SERVICE ACCOUNT KEY CREATION

### Step 1

```bash
gcloud org-policies describe iam.disableServiceAccountKeyCreation \
  --folder=278994416390
````

### Step 2

```bash
gcloud iam service-accounts list \
  --project=PROJECT_ID
```

### Step 3

```bash
gcloud iam service-accounts keys create test-key.json \
  --iam-account=SERVICE_ACCOUNT_EMAIL
```

---

## SKIP DEFAULT NETWORK CREATION

### Step 1

```bash
gcloud org-policies describe compute.skipDefaultNetworkCreation \
  --folder=278994416390
```

### Step 2

```bash
gcloud projects create TEST_PROJECT_ID \
  --folder=278994416390
```

### Step 3

```bash
gcloud compute networks list \
  --project=TEST_PROJECT_ID
```

---

## RESTRICT RESOURCE SERVICE USAGE — NOT WORKING

### Step 1

```bash
gcloud org-policies describe gcp.restrictServiceUsage \
  --folder=278994416390
```

### Step 2

```bash
gcloud org-policies describe gcp.restrictServiceUsage \
  --folder=278994416390 \
  --format="yaml(spec.rules)"
```

### Step 3

```bash
gcloud services enable translate.googleapis.com \
  --project=PROJECT_ID
```

---

## UNIFORM BUCKET LEVEL ACCESS — ERROR OCCURRED BY NON-CMEK

### Step 1

```bash
gcloud org-policies describe storage.uniformBucketLevelAccess \
  --folder=278994416390
```

### Step 2

```bash
gcloud storage buckets create gs://YOUR_UNIQUE_TEST_BUCKET \
  --project=PROJECT_ID \
  --location=US
```

### Step 3

```bash
gcloud storage buckets describe gs://YOUR_UNIQUE_TEST_BUCKET \
  --format="default(uniform_bucket_level_access)"
```

### Step 4

```bash
gcloud storage buckets update gs://YOUR_UNIQUE_TEST_BUCKET \
  --no-uniform-bucket-level-access
```

---

## RESTRICT WHICH SERVICES MAY CREATE RESOURCES WITHOUT CMEK

### Step 1

```bash
gcloud org-policies describe gcp.restrictNonCmekServices \
  --folder=278994416390
```

### Step 2

```bash
gcloud org-policies describe gcp.restrictNonCmekServices \
  --folder=278994416390 \
  --format="yaml(spec.rules)"
```

### Step 3

```bash
gcloud kms keyrings create test-keyring \
  --location=global \
  --project=test-project-506110

gcloud kms keys create test-key \
  --keyring=test-keyring \
  --location=global \
  --purpose=encryption \
  --project=PROJECT_ID
```

### Step 4

```bash
gcloud storage buckets create gs://test-uniform-access-bucket \
  --project=test-project-506110 \
  --location=US
```

---

## RESTRICT DISK TYPE TO PD-BALANCED — CUSTOM

### Step 1

```bash
gcloud org-policies describe custom.restrictDiskTypes \
  --folder=278994416390
```

### Step 2

```bash
gcloud org-policies describe custom.restrictDiskTypes \
  --folder=278994416390 \
  --format="yaml(spec.rules)"
```

### Step 3

```bash
gcloud compute disks create trusted-disk-test \
  --project=test-project-506110 \
  --zone=us-central1-a \
  --type=pd-ssd \
  --size=10GB
```

### Step 4

```bash
gcloud compute disks create trusted-disk-approved \
  --project=test-project-506110 \
  --zone=us-central1-a \
  --type=pd-balanced \
  --size=10GB
```

---

## DEFINED ALLOWED EXTERNAL IPs FOR VM INSTANCES

### Step 1

```bash
gcloud org-policies describe compute.vmExternalIpAccess \
  --folder=278994416390
```

### Step 2

```bash
gcloud org-policies describe compute.vmExternalIpAccess \
  --folder=278994416390 \
  --format="yaml(spec.rules)"
```

### Step 3

```bash
gcloud compute instances create external-ip-test \
  --project=PROJECT_ID \
  --zone=us-central1-a \
  --machine-type=e2-micro \
  --image-family=debian-12 \
  --image-project=debian-cloud
```

---

## RESTRICT VM MACHINE TYPES — custom.restrictVmMachineType

### Step 1

```bash
gcloud org-policies describe custom.restrictVmMachineType \
  --folder=278994416390
```

### Step 2

```bash
gcloud org-policies describe custom.restrictVmMachineType \
  --folder=278994416390 \
  --format="yaml(spec.rules)"
```

### Step 3

```bash
gcloud compute instances create test-vm-restricted \
  --zone=us-central1-a \
  --machine-type=n2d-standard-2 \
  --project=test-project-506110
```

### Step 4

```bash
gcloud compute instances create test-vm-allowed \
  --zone=us-central1-a \
  --machine-type=n1-standard-1 \
  --project=test-project-506110
```

---

## ALLOWED VPC CONNECTOR EGRESS SETTINGS (CLOUD FUNCTIONS)

### Step 1

```bash
gcloud resource-manager org-policies describe cloudfunctions.allowedVpcConnectorEgressSettings \
  --folder=278994416390
```

### Step 2

```bash
gcloud org-policies describe cloudfunctions.allowedVpcConnectorEgressSettings \
  --folder=278994416390
```

### Step 3

```bash
gcloud org-policies describe cloudfunctions.allowedVpcConnectorEgressSettings \
  --folder=278994416390 \
  --format="yaml(spec.rules)"
```

### Step 4

```bash
gcloud compute networks vpc-access connectors list \
  --region=us-central1 \
  --project=test-project-506110
```

### Step 5

```bash
gcloud functions deploy test-vpc-egress \
  --runtime=python312 \
  --region=us-central1 \
  --source=. \
  --entry-point=hello_http \
  --vpc-connector=test-vpc-connector \
  --egress-settings=ALL_TRAFFIC
```

### Step 6

```bash
gcloud functions deploy test-vpc-egress-invalid \
  --no-gen2 \
  --runtime=python312 \
  --region=us-central1 \
  --source=. \
  --entry-point=hello_http \
  --trigger-http \
  --vpc-connector=test-vpc-connector \
  --egress-settings=PRIVATE_RANGES_ONLY
```

---

# END OF VALIDATION COMMANDS

```
```
