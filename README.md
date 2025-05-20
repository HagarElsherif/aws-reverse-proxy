# aws-terraform-reverse-proxy

This project sets up a high available AWS infrastructure using Terraform, featuring a **reverse proxy architecture**. It includes public and private subnets, EC2 instances, and two layers of Application Load Balancers (ALBs). Nginx runs on proxy instances to reverse proxy requests from a public ALB to backend instances via an internal ALB.

---

## Architecture Overview

Public ALB (HTTP)
|
v
+--------------------+
| Proxy EC2 Instances| <-- Nginx Reverse Proxy
+--------------------+
|
v
Internal ALB (Private)
|
v
+---------------------+
| Backend EC2 Instances | <-- Nginx Web Servers
+---------------------+


---

## Features

- VPC with public and private subnets across 2 AZs
- EC2 Instances:
  - **Proxy Layer** (public) with Nginx reverse proxy
  - **Backend Layer** (private) with Nginx web servers
- Public ALB → Proxy EC2 → Internal ALB → Backend EC2
- Target Groups and Health Checks
- SSH Key Pair for access
- Security Groups with least-privilege rules
- Fully automated using Terraform

---

## Getting Started

### 1. Clone the repo

```bash
git clone https://github.com/HagarElsherif/aws-reverse-proxy
cd aws-terraform-reverse-proxy

---

### 3. Initialize Terraform
```bash
terraform init
---
4. Apply the infrastructure

terraform apply

📎 The private key will be saved locally as terraform-key.pem. Run:

chmod 400 terraform-key.pem

Testing
Open the Public ALB DNS in a browser.

You should be routed through the proxy EC2 to the backend via the internal ALB.

You can also SSH into a proxy instance:

ssh -i terraform-key.pem ec2-user@<proxy-public-ip>
curl http://localhost

Author
Hagar Mohamed Elsherif


---

License
MIT License

