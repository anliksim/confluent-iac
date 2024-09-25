variable "cc_users_list" {
  type = list(string)
  default = [
    "user1@example.com",
    "user2@example.com"
  ]
}

# loops over the list of users and creates invitations for them
resource "confluent_invitation" "cc_invitation" {
  for_each  = toset(var.cc_users_list)
  email     = each.value
  auth_type = "AUTH_TYPE_LOCAL"
  allow_deletion = true
}

# loops over the list of users and create a data object. 
# if the invitation has not yet been accepted, this results in "Error: error reading User: User with "email"="___" was not found"
data "confluent_user" "cc_user" { 
  for_each  = toset(var.cc_users_list)
  email     = each.value
  depends_on = [
    confluent_invitation.cc_invitation
  ]
}