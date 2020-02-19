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
DISK_IMG = 'urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU18-64-STD'
# Create a portal object,
pc = portal.Context()

pc.defineParameter("slaveCount", "Number of slave nodes",
                   portal.ParameterType.INTEGER, 1)
pc.defineParameter("osNodeType", "Hardware Type",
                   portal.ParameterType.NODETYPE, "",
                   longDescription='''A specific hardware type to use for each
                   node. Cloudlab clusters all have machines of specific types.
                     When you set this field to a value that is a specific
                     hardware type, you will only be able to instantiate this
                     profile on clusters with machines of that type.
                     If unset, when you instantiate the profile, the resulting
                     experiment may have machines of any available type
                     allocated.''')
params = pc.bindParameters()


def create_request(request, role, ip, worker_num=None):
    if role == 'm':
        name = 'master'
    elif role == 's':
        name = 'worker-{}'.format(worker_num)
    req = request.RawPC(name)
    if params.osNodeType:
        req.hardware_type = params.osNodeType
    req.routable_control_ip = True
    req.disk_image = DISK_IMG
    req.addService(pg.Execute(
        'sh',
        'sudo -H bash /local/repository/bootstrap.sh {} > /local/logs/setup.log 2>/local/logs/error.log'.format(role)))
    iface = req.addInterface(
        'eth9', pg.IPv4Address(ip, '255.255.255.0'))
    return iface


# Create a Request object to start building the RSpec.
request = pc.makeRequestRSpec()

# Link link-0
link_0 = request.LAN('link-0')
link_0.Site('undefined')

# Master Node
iface = create_request(request, 'm', '10.10.1.1')
link_0.addInterface(iface)

# Slave Nodes
for i in range(params.slaveCount):
    iface = create_request(
        request, 's', '10.10.1.{}'.format(i + 2), worker_num=i)
    link_0.addInterface(iface)


# node_worker_0 = request.RawPC('worker-0')
# node_worker_0.routable_control_ip = True
# node_worker_0.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU18-64-STD'
# node_worker_0.addService(pg.Execute(
#     '/bin/sh', 'sudo git clone https://github.com/makemebitter/spark-cloudlab.git /local/setup; sudo -H bash /local/setup/bootstrap.sh s > /local/logs/setup.log'))
# iface0 = node_worker_0.addInterface('eth1')

# # Node master
# node_master = request.RawPC('master')
# node_master.routable_control_ip = True
# node_master.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU18-64-STD'
# node_master.addService(pg.Execute(
#     '/bin/sh', 'sudo git clone https://github.com/makemebitter/spark-cloudlab.git /local/setup; sudo -H bash /local/setup/bootstrap.sh m > /local/logs/setup.log'))
# iface1 = node_master.addInterface('eth1')


# Print the generated rspec
pc.printRequestRSpec(request)
