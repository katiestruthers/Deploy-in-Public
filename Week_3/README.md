# Week 3 - Multi-availability Zone EC2 Deployment with Load Balancer
## Project Overview
- Setup AWS account
  - Create an IAM Role for Systems Manager

- Refactor main.tf to use modules and variables, starting with the VPC module

- Opt for [AWS Systems Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html) over a bastion host

- Deploy two NGINX servers that display custom HTML pages into private subnets in two different availability zones

## Resources
- Divide your subnets from 2 to 4: [Subnet Calculator](https://www.davidc.net/sites/default/subnets/subnets.html)
- Walkthrough: [Managing Application Load Balancer (ALB) with Terraform](https://spacelift.io/blog/terraform-alb)

## Final Result