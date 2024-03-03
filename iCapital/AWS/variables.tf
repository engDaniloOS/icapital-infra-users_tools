variable "bucket_name"{
    type = string
    description = "Nome do bucket"
}

variable "default_tags" {
  type = object({
    feature = string
  })
  default = {
    feature = "user_tools"
  }
}