create an S3 bucket to be used to store terraform state files
aws s3api create-bucket --bucket terraformstatebucket9391

## Keypair
generate keypair locally - ssh-keygen -t rsa 
attach keys to EC2 isntances