data "ibm_resource_group" "rg" {
  name = var.resource_group
}

data "ibm_is_ssh_key" "sshkey1" {
  name = var.ssh_key_name
}

resource "ibm_is_vpc" "vpc1" {
  name = var.vpc_name
  address_prefix_management = "auto"
  resource_group = data.ibm_resource_group.rg.id
}

resource "ibm_is_vpc_address_prefix" "vpc-ap1" {
  name = "vpc-ap1"
  zone = var.zone1
  vpc  = ibm_is_vpc.vpc1.id
  cidr = var.zone1_cidr
}

resource "ibm_is_vpc_address_prefix" "vpc-ap2" {
  name = "vpc-ap2"
  zone = var.zone2
  vpc  = ibm_is_vpc.vpc1.id
  cidr = var.zone2_cidr
}

resource "ibm_is_vpc_address_prefix" "vpc-ap3" {
  name = "vpc-ap3"
  zone = "${var.zone3}"
  vpc  = "${ibm_is_vpc.vpc1.id}"
  cidr = "${var.zone3_cidr}"
}

resource "ibm_is_subnet" "subnet1alv" {
  name            = "subnet1alv"
  vpc             = ibm_is_vpc.vpc1.id
  zone            = var.zone1
  ipv4_cidr_block = var.zone1_cidr
  depends_on      = [ibm_is_vpc_address_prefix.vpc-ap1]
  resource_group = data.ibm_resource_group.rg.id
}

resource "ibm_is_subnet" "subnet2alv" {
  name            = "subnet2alv"
  vpc             = ibm_is_vpc.vpc1.id
  zone            = var.zone2
  ipv4_cidr_block = var.zone2_cidr
  depends_on      = [ibm_is_vpc_address_prefix.vpc-ap2]
  resource_group = data.ibm_resource_group.rg.id
}

resource "ibm_is_subnet" "subnet3alv" {
  name            = "subnet3alv"
  vpc             = ibm_is_vpc.vpc1.id
  zone            = var.zone3
  ipv4_cidr_block = var.zone3_cidr
  depends_on      = [ibm_is_vpc_address_prefix.vpc-ap3]
  resource_group = data.ibm_resource_group.rg.id
}

resource "ibm_is_instance" "instance-alv-1" {
  name    = "instance-alv-1"
  image   = var.image
  profile = var.profile
  primary_network_interface {
    subnet = ibm_is_subnet.subnet1alv.id
  }
  vpc  = ibm_is_vpc.vpc1.id
  zone = var.zone1
  keys = [data.ibm_is_ssh_key.sshkey1.id]
  user_data = data.template_cloudinit_config.cloud-init-apptier.rendered
  resource_group = data.ibm_resource_group.rg.id
}

resource "ibm_is_instance" "instance-alv-3" {
  name    = "instance-alv-3"
  image   = var.image
  profile = var.profile

  primary_network_interface {
    subnet = ibm_is_subnet.subnet3alv.id
  }
  vpc  = ibm_is_vpc.vpc1.id
  zone = var.zone3
  keys = [data.ibm_is_ssh_key.sshkey1.id]
  user_data = data.template_cloudinit_config.cloud-init-apptier.rendered
  resource_group = data.ibm_resource_group.rg.id
}

resource "ibm_is_instance" "instance-alv-2" {
  name    = "instance-alv-2"
  image   = var.image
  profile = var.profile
  primary_network_interface {
    subnet = ibm_is_subnet.subnet2alv.id
  }
  vpc  = ibm_is_vpc.vpc1.id
  zone = var.zone2
  keys = [data.ibm_is_ssh_key.sshkey1.id]
  user_data = data.template_cloudinit_config.cloud-init-apptier.rendered

  resource_group = data.ibm_resource_group.rg.id
}

resource "ibm_is_security_group_rule" "sg1_tcp_rule_22" {
  group     = ibm_is_vpc.vpc1.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = "22"
    port_max = "22"
  }
}

resource "ibm_is_security_group_rule" "sg1_tcp_rule_80" {
  group     = ibm_is_vpc.vpc1.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = "80"
    port_max = "80"
  }
}
