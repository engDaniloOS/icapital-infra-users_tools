variable "bucket_name"{
    type = string
    description = "Nome do bucket"
    default = "user-tools"
}


variable "default_tags" {
  type = object({
    feature = string
  })
  default = {
    feature = "user_tools"
  }
}