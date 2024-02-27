This document will lead you to containerize MediaWiki with the help of Terraform and AWS EKS
1. Tech Stack
AWS EKS
AWS RDS
Terraform

2. Provision Infrastructure
Here, I have used AWS & Terraform to provision node in AWS EKS and AWS RDs

Steps
1. Make sure aws cli, terraform is set up on the machine 
sudo apt-get update
sudo apt-get install awscli
sudo apt install unzip
wget https://releases.hashicorp.com/terraform/X.Y.Z/terraform_X.Y.Z_linux_amd64.zip
unzip terraform_X.Y.Z_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform version
2. Configure aws cli with proper permissions
3. Run the command :- terraform init; terraform plan -var "db_username=<passtheusername>" -var "db_password=<passthedbpassword>" ;
terraform apply -var "db_username=<passtheusername>" -var "db_password=<passthedbpassword>" 
4. It will output the RDS endpoint created
5. After the infrastructure is setup run the command: aws eks update-kubeconfig --region us-east-1 --name sashukla-eks-01
6. Run the command : terraform init; terraform plan; terraform apply ; in application folder
7. Run the command : kubectl get service, it will output the endpoint 
8. Hit the url on port 80 and it will open the mediawiki setup page
9. Enter the RDS database endpoint, db_password, db_password and db name = "my-db-instance"
10. Copy the LocalSettings.php file to running Pod by running the command : kubectl exec -it <pod> bash
11. Add the file to /var/www/html folder
12. MediaWiki is setup 


Containerization
I have used official mediawiki docker image for mediawiki deployment
I have AWS RDS instance for the mysql setup
Once you run the terraform apply for vpc.tf file it will create the infrastructure.
Once to run the terraform apply for mediawiki.tf the mediawiki application should be up and running
once all pods up and running hit the URL and you can see the mediawiki setup page.
now we got the mediawiki up and running.
Planned well to make this. due to low time I couldn't acheive all my thoughts. I can explain in discussion if it's possible.

** Thanks for reading! **

