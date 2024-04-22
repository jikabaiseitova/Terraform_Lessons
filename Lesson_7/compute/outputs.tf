output "remote_state" {
  value = data.terraform_remote_state.networking
}

output "instances" {
  value = {for i, v in aws_instance.instance : i => v.id}
}

