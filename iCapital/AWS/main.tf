provider "aws"{
    region = "us-east-1"
}

terraform {
    backend "remote" {
        # The name of your Terraform Cloud organization.
        organization = "testen"

        # The name of the Terraform Cloud workspace to store Terraform state files in.
        workspaces {
            name = "teste"
        }
    }
}