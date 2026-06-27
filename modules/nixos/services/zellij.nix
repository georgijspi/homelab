{ vars, ... }:

{
  users.users.${vars.host.primaryUser.name}.linger = true;
}
