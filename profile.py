"""spark standalone WIP"""

#
# NOTE: This code was machine converted. An actual human would not
#       write code like this!
#

# Import the Portal object.
import geni.portal as portal
# Import the ProtoGENI library.
import geni.rspec.pg as pg
# Import the Emulab specific extensions.
import geni.rspec.emulab as emulab

# Create a portal object,
pc = portal.Context()

# Create a Request object to start building the RSpec.
request = pc.makeRequestRSpec()

# Node worker-0
node_worker_0 = request.RawPC('worker-0')
node_worker_0.routable_control_ip = True
node_worker_0.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU18-64-STD'
node_worker_0.addService(pg.Execute(
    '/bin/sh', 'sudo git clone https://github.com/makemebitter/spark-cloudlab.git /local/setup; sudo -H bash /local/setup/bootstrap.sh s > /local/logs/setup.log'))
iface0 = node_worker_0.addInterface('eth1')

# Node master
node_master = request.RawPC('master')
node_master.routable_control_ip = True
node_master.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU18-64-STD'
node_master.addService(pg.Execute(
    '/bin/sh', 'sudo git clone https://github.com/makemebitter/spark-cloudlab.git /local/setup; sudo -H bash /local/setup/bootstrap.sh m > /local/logs/setup.log'))
iface1 = node_master.addInterface('eth1')

# Link link-0
link_0 = request.LAN('link-0')
link_0.Site('undefined')
link_0.addInterface(iface1)
link_0.addInterface(iface0)


# Print the generated rspec
pc.printRequestRSpec(request)
