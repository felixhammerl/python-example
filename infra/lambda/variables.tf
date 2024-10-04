variable "bucket_name" {
  type = string
}

variable "zip_path" {
  type = string
}

variable "function_name" {
  type = string
}

variable "handler" {
  type = string
}

variable "iam_policy_json" {
  type = string
}

variable "env" {
  type    = map(any)
  default = {}
}

variable "memory" {
  type    = number
  default = 512
}

variable "timeout" {
  type    = number
  default = 300
}
