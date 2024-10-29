* Update DNS to update only for the right VMs

* Terraform AWS Transfer Family but don't leave running

* Better handling of RCON password in AWS secrets. Allow for RCON password
  to be specified at boot of container by ENV and not persist in the
  server.properties like it currently does.

* Parameterize the auto shutdown script to allow an ENV var to be passed
  in that controls the length of time we wait to shutdown

* Make it easy to swap volumes or revert to effemeral storage for one-day
  campaigns with new worlds. The server start API should be able to do
  this.

* Create a single page app hosted on the web that gives server status
  and allows the user to trigger the server start sequence API

* Generate world map periodically and present on the web
