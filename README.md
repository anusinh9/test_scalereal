# test_scalereal
The repo is created to store source code for terraform required as part of spinning INFRA for problem solving as below steps

👨‍💻 Preparation

1 - Installing terraform binary before we start up
 
One can directly get the latest terraform binar from " https://releases.hashicorp.com/terraform/0.14.3 " based on the release version
or directly you can login to your local unix machine (which we have used in this setup) and follow below steps:

$ cd ~
$ wget https://releases.hashicorp.com/terraform/0.14.3/terraform_0.14.3_linux_amd64.zip
$ unzip terraform_0.14.3_linux_amd64.zip   (this is will unzip the binary package downloaded from above step)
$ sudo cp terraform /usr/bin/terraform  (this is will allow terraform binary to be placed in your users current path)
you can check if terraform binary has been placed successfully via below 2 commands

    $ which terraform
    $ terraform --version


First of all, download the source code
    $ git clone https://github.com/anusinh9/test_scalereal.git
    $ cd test_scalereal

For the sake for simplicty if you are not using AWS CLI, you can use the the access key and secret access key provided by AMAZON as environment variables to prevent it from using hard-coded secrets. Find below examples (these secrets are dummy and wont work in real life)

    $ export AWS_ACCESS_KEY_ID="AKIAXHUWH2637XZGONJ33"
    $ export AWS_SECRET_ACCESS_KEY="WKp6DFgej77jje9U0jMT4a7ceD9r66SlgbsTRmUabcd"
    $ export AWS_DEFAULT_REGION="ap-south-1"  #ap-south-1 (Mumbai region has been selected to avoid the latency)
    
💡 Pro Tip : If you have AWS CLI configured locally, Terraform can use that configuration too for authentication with AWS which is more robust as we have options of selection of different profiles for authentication.

We will be using remote backend for our configuration. If you open the backend.tf file, you will find the below configuration block
    
      terraform {
    backend "s3" {
        bucket = "tfs-state-anubhav.demo2"
        key    = "scalereal/s3/terraform.tfstate"
        region = "ap-south-1"
        dynamodb_table = "tfs-state-locking1"
        encrypt = true
        access_key = "AKIAXHUWH2637XZGONJ3"
        secret_key = "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"
    }
}
 #from version 0.11 and later interpolation can be ignored we can also use "AWS_ACCESS_KEY_ID" but for versions compatibility we will stick with it as during terraform plan it will throw only warnings but no errors.
 
 ⚠️  Note : However to setup the remote backend on S3 bucket we first need to have the required pre-requisites in place (S3 bucket , dynamodb table for state lock ) and thus we use the local backend for the first time to spin up the infrastructure we require for remote backend which in this is S3 bucket. You can refer to "S3-remote-backend.tf"
 
    resource "aws_s3_bucket" "tfs-state-anubhav1" {
    bucket = "tfs-state-anubhav.demo2"
    lifecycle {
        prevent_destroy = true
    }
    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }

     }

 }
}

resource "aws_dynamodb_table" "tfs-locks" {
    name         = "tfs-state-locking1"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"
    attribute {
      name       = "LockID"
      type       = "S"
    }

}

resource "aws_dynamodb_table" "records-table" {
    name         = "records"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "UserID"
    attribute {
      name       = "UserID"
      type       = "S"
    }

}

provider "aws" {
  region     = "${AWS_DEFAULT_REGION}"
  access_key = "${AWS_ACCESS_KEY_ID}"
  secret_key = "${AWS_SECRET_ACCESS_KEY}"
}

💡 The additional dynamodb table " records" being provisioned in above code is for later use by lambda functions hence we will discuss about it later.


🚀 Execution
Once the above code has been dowloaded first setup the remote backend infrastructur using terraform

    $ terraform init
    $ terraform apply -auto-approve
Post this we would successfully spinned up 
1 - S3 bucket for storing remote backends
2 - 2 Dynamodb Table ( tfs-state-locking1 - which will be used for locking remote state , records - which will use later to store csv data fetched from S3 buckets into dynamodb post lambda trigger) 

Now we would run the backend.tf to change the local backend to remote backed but beware for any change in backend we need to get it initialize again using " terraform init"


🧐 Testing
Now we have resources we need to provision to achieve our csv2dynamodb we have few files specifically for this namely (lambda.tf - for provisioning / lambda.py - for lambda function which uses python as its runtime)
Upload a sample .csv file (attached in this repo for sample on S3 via aws cli or GUI)
     aws s3 cp sample_csv/records.csv s3://anubhav-bucketforlambdatrigger/records.csv  (the hard way)  or via accessing the S3 GUI and uploading it.
    
    aws dynamodb scan --table-name records (the hard way) or just search for DynamoDB in aws services portal and check for items in table.
    
    You will be see teh data entered into csv form in now into table format.
    
🌐 Working with the REST API

However I'm still working to check and create api endpoints for remote operations (create,update,read and delete on dynamodb) hence I am combining it in a different folder in this repo just to make sure the rest of the codes works.
📝 Note: The current projects support infrstructure provisioning using terraform and lambda triggers associated with S3 buckets reads the event which is based on "s3:ObjectCreated:*" and  splits the data and write it to dynamoDB.

