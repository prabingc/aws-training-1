## In this lab we are deploying a single tier web applicaiton. The resources we will be creating here is 1 public facing website backed by nginx running on a EC2 instance. EC2 instances are behind a AutoScaling which scales up and down based on CPU usage. 

  ### Tools used: 
     - Packer for AMI creation.
     - Terraform to build all the infrastructure. 
      

## aws-training-1  (Please view this as RAW if you see any formatting issues)
1) Launch a new instance with default Amazon Linux AMI. Use EBS volume to be at least 16GB. Under Advance details add following to 
    IAM instance profile : EC2_role

    "User data":
```
#!/bin/bash
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install packer
yum -y install terraform
```
3) Login to instance using EC2 connect and clone the github repo (adding your keys first).
   ```
     mkdir capstone1
     cd capstone1
     git clone git@github.com:prabingc/aws-training-1.git
   ```

   Please refer https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account for adding your ssh keys.

5) Run packer to build a ami with Nginx
   ```
   cd aws-training-1/packer
   packer init .
   packer validate .
   packer build .
   ```

7) Run terraform to build infra.
   ```
    cd ../build_infra/
    terraform init
    terraform plan
```
### Future improvements:
    - Add support of 443 traffic on existing ALB.
    - Add on this solution to modify existing single tier application to multi-tier solution (Web/App/DB). 
    - Instead of using EC2 as backend we can use container running on Kubernetes cluster. 
