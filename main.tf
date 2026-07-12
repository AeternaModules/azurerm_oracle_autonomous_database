data "azurerm_key_vault_secret" "admin_password" {
  for_each     = { for k, v in var.oracle_autonomous_databases : k => v if v.admin_password_key_vault_id != null && v.admin_password_key_vault_secret_name != null }
  name         = each.value.admin_password_key_vault_secret_name
  key_vault_id = each.value.admin_password_key_vault_id
}
resource "azurerm_oracle_autonomous_database" "oracle_autonomous_databases" {
  for_each = var.oracle_autonomous_databases

  admin_password                   = each.value.admin_password != null ? each.value.admin_password : try(data.azurerm_key_vault_secret.admin_password[each.key].value, null)
  resource_group_name              = each.value.resource_group_name
  national_character_set           = each.value.national_character_set
  name                             = each.value.name
  mtls_connection_required         = each.value.mtls_connection_required
  location                         = each.value.location
  license_model                    = each.value.license_model
  db_workload                      = each.value.db_workload
  display_name                     = each.value.display_name
  data_storage_size_in_tbs         = each.value.data_storage_size_in_tbs
  compute_model                    = each.value.compute_model
  compute_count                    = each.value.compute_count
  character_set                    = each.value.character_set
  backup_retention_period_in_days  = each.value.backup_retention_period_in_days
  auto_scaling_for_storage_enabled = each.value.auto_scaling_for_storage_enabled
  auto_scaling_enabled             = each.value.auto_scaling_enabled
  db_version                       = each.value.db_version
  tags                             = each.value.tags
  allowed_ips                      = each.value.allowed_ips
  customer_contacts                = each.value.customer_contacts
  subnet_id                        = each.value.subnet_id
  virtual_network_id               = each.value.virtual_network_id

  dynamic "long_term_backup_schedule" {
    for_each = each.value.long_term_backup_schedule != null ? [each.value.long_term_backup_schedule] : []
    content {
      enabled                  = long_term_backup_schedule.value.enabled
      repeat_cadence           = long_term_backup_schedule.value.repeat_cadence
      retention_period_in_days = long_term_backup_schedule.value.retention_period_in_days
      time_of_backup           = long_term_backup_schedule.value.time_of_backup
    }
  }
}

