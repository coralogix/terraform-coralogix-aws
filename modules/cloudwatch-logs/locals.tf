locals {
  # Converting var.log_groups to a map to get away from using the 'count' meta-argument
  # in exchange for using the 'for_each' meta-argument. This helps avoid unnecessary
  # churn in terraform deploys when the order of the log_groups changes.
  #
  # Keys in the map are the log group names. Values are used for the key in the 'allowed_triggers'
  # object passed to the lambda modules. The way that object is then used in the downstream resource
  # requires a length of 100 characters or less and cannot contain "/" characters. If the log group name is longer than 100 characters,
  # we use the first 95 characters and append the first 4 characters of the sha256 hash of the log group
  # name to ensure uniqueness.
  log_groups = {
    for group in var.log_groups : group =>
    length(group) > 100 ? "${substr(replace(group, "/", "_"), 0, 95)}_${substr(sha256(group), 0, 4)}" : replace(group, "/", "_")
  }
}
