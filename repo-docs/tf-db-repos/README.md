# gsoft-<project>-db

> **NOTE:** This is a general README for all db-repos

This project manage the IaC of Clusters and DBs.

# Dependencies
This project depends on `https://github.com/gsoftcolombia/gsoft-<project>-infrastructure`. This will create Clusters on the specified VPC.

# What else is included in this repo

## mysql-executor

Not only Terraform, it also includes a Github Workflow called `mysql-executor`. This executor can be executed only on main, and it executes some SQL scripts defined in the `/users` folder. This is the manner we manage the creation of different users, but wachout, this SQL in `users/` is only a raw template, it will not include real passwords from all users.

### How mysql-executor works

This workflow uses another project: https://github.com/gsoftcolombia/mysql-ssm-executor 

Passwords are in SSM Parameter Store in AWS: This script receive the raw template and catch all ssm parameters, later it builds a real SQL script that will be executed.

The good part is that, you as developer doesnt know what is the value of the passwords, however you can create the different users in a kind of iac.

