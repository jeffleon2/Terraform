output "addresses" {
  value = {
    aws          = module.aws.network_address
    gcp          = module.gcp.network_address
    loadbalancer = module.loadbalancer.network_address
  }
}