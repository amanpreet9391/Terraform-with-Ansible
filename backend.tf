terraform{
    required_version = ">=0.12.0"

    backend "s3"{
    profile = "default"
    key = "terraforstatefile"
    bucket = "terraformstatebucket9391"    
    region = "us-east-1"
  }
}