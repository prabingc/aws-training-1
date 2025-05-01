# aws-training-1  (Please view this as RAW, I wasn't able to make the markup work)
1) Launch a new instance with default Amazon Linux AMI. Use EBS volume to be at least 16GB. Under Advance details add following to 
    IAM instance profile : EC2_role

    "User data":
#!/bin/bash
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install packer
yum -y install terraform

3) Login to instance using EC2 connect and clone the github repo (adding your keys first).
     mkdir capstone1
     cd capstone1
     git clone git@github.com:prabingc/aws-training-1.git

   Please refer https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account for adding your ssh keys.

4) Run packer to build a ami with Nginx
   cd aws-training-1/packer
   packer init .
   packer validate .
   packer build .

5) Run terraform to build infra.
    cd ../build_infra/
    terraform init
    terraform plan

