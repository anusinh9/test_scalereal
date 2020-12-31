terraform {
    backend "s3" {
        bucket = "tfs-state-anubhav.demo2"
        key    = "scalereal/s3/terraform.tfstate"
        region = "ap-south-1"
        dynamodb_table = "tfs-state-locking1"
        encrypt = true
        access_key = "${AWS_ACCESS_KEY_ID}"
        secret_key = "${AWS_SECRET_ACCESS_KEY}"
    }
}
