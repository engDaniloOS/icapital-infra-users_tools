variable "bucket_name"{
    type = string
    description = "Nome do bucket"
    default = "teste"
}

variable "default_tags" {
  type = object({
    feature = string
  })
  default = {
    feature = "user_tools"
  }
}