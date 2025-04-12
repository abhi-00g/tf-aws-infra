# tf-aws-infra
We are going to start setting up networking in AWS, such as Virtual Private Cloud (VPC), Internet Gateway, Route Table, and Routes. We will use Terraform for infrastructure setup and teardown.

# Steps for demo
1. Download the zip from canvas and unzip the zip file
2. Go to terminal and go to the location of the tf-aws-infra folder
3. Use terraform init to initialize terraform in current directory
4. Use terraform validate to check for correctness of terraform files
5. Use terraform plan -var="aws_profile=demo/dev" to show waht is goining to be created 
6. Use terraform apply -var="aws_profile=demo/dev" --auto-approve to apply the infrastructure
7. Use terraform destroy -var="aws_profile=demo/dev" --auto-approve to destroy all resources created by terraform

The command to import the certificate is
aws acm import-certificate \
  --certificate fileb://demo_abhishekgade_me/demo_abhishekgade_me.crt \
  --private-key fileb://demo_abhishekgade_me/demoenv.key \
  --certificate-chain fileb://demo_abhishekgade_me/demo_abhishekgade_me.ca-bundle \
  --region us-east-1 \
  --profile demo