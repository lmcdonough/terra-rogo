# Terraform AWS 3-Tier Web App Scaffolding (DRY, Modular, HA)

## Overview

This project provides a modular and reusable Terraform setup for deploying a 3-tier web application on AWS. The architecture is designed to be DRY (Don't Repeat Yourself), scalable, and maintainable, following best practices for infrastructure as code.
The setup includes a VPC with public and private subnets, an Application Load Balancer (`ALB`), Auto Scaling Groups (`ASG`) for EC2 instances, and a PostgreSQL RDS instance. The project is structured to support multiple environments (`dev`, `stage`, `prod`) with shared modules for reusability.

### Diagrams

#### Directory Structure

```mermaid
graph LR
    Root[Root Directory]
    Root --> Global[global]
    Root --> Management[management]
    Root --> Dev[dev]
    Root --> Stage[stage]
    Root --> Prod[prod]
    Root --> Modules[modules]

    Dev --> DevMain[main.tf]
    Dev --> DevVars[variables.tf]
    Dev --> DevOut[outputs.tf]

    Stage --> StageMain[main.tf]
    Stage --> StageVars[variables.tf]
    Stage --> StageOut[outputs.tf]

    Prod --> ProdMain[main.tf]
    Prod --> ProdVars[variables.tf]
    Prod --> ProdOut[outputs.tf]

    Modules --> VPC[vpc]
    Modules --> EC2[ec2]
    Modules --> ALB[alb]
    Modules --> ASG[autoscaling]
    Modules --> RDS[rds]
    Modules --> SG[security_groups]
    Modules --> Net[networking]
    Modules --> IAM[iam]
```

#### Infrastructure Overview

```mermaid
graph TD
    VPC --> PublicSubnet1
    VPC --> PublicSubnet2
    VPC --> PrivateSubnet1
    VPC --> PrivateSubnet2
    ALB[ALB]
    PublicSubnet1 --> ALB
    PublicSubnet2 --> ALB
    ALB --> ASG[Auto Scaling Group]
    ASG --> EC2A[EC2 App 1]
    ASG --> EC2B[EC2 App 2]
    PrivateSubnet1 --> RDS
    PrivateSubnet2 --> RDS
    EC2A --> RDS
    EC2B --> RDS
```

#### Walkthrough

1. `mkdir terraform-aws-webapp && cd terraform-aws-webapp` — Create root project directory.
2. `mkdir dev stage prod global management` — Create environment folders.
3. `mkdir -p modules/{vpc,ec2,alb,autoscaling,rds,security_groups,networking,iam}` — Create reusable modules.
4. `touch {dev,stage,prod}/main.tf {dev,stage,prod}/variables.tf {dev,stage,prod}/outputs.tf` — Add base TF files per environment.
5. `global/main.tf`: Configure AWS provider and backend for shared state.
6. `modules/vpc`: Define VPC, subnets, IGW, NAT, RTs.
7. `modules/security_groups`: Define SGs for ALB, EC2, RDS with secure rules.
8. `modules/alb`: Define ALB, listeners, target groups.
9. `modules/autoscaling`: Define ASG, launch templates, scaling policies.
10. `modules/ec2`: Handle instance AMI, userdata, profiles.
11. `modules/rds`: Define subnet group, Postgres instance, SGs.
12. Wire modules in `dev/main.tf` (and other envs) using inputs and outputs.
13. Define `variables.tf` in each env for module inputs.
14. Define `outputs.tf` in each module/env to expose key values.
15. `cd dev && terraform init && terraform validate` — Initialize and validate setup.
16. (Optional) Add IAM module to manage roles and instance profiles.
17. `terraform plan -out=tfplan` — Preview changes and verify before apply.
18. `terraform apply tfplan` — Apply changes to create infrastructure.
19. `terraform destroy` — Clean up resources when done
