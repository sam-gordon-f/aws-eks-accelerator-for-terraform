# Deployment / Codepipeline

1. [Intro](#intro)
2. [Setup Instructions](#setupinstructions)

---

## Intro

This is a `plug and play` AWS codepipeline module that can be instantiated to monitor for code changes, and then build / test / deploy the terraform accelerator into an environment of your choosing 

---

## Setup Instructions

1. Navigate to the terraform folder

```
cd deploy/ci_cd/codepipeline/terraform
```

2. run a terraform plan / apply

```
terraform plan -var-file __variables/pipeline.tfvars
terraform apply -var-file __variables/pipeline.tfvars
```