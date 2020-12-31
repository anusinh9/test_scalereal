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