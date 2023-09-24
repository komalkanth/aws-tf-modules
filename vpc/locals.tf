locals {
  default_tags = {
    Environment  = var.environment
    Organization = var.organization
  }
}

/* locals public_subnet_set takes below input
public_subnet_cidr_map  = {
    "us-east-1a": {
      "subnet-1": "10.1.0.0/24"
    }
    "us-east-1b": {
      "subnet-1": "10.1.1.0/24"
      }
    "us-east-1c": {
      "subnet-1": "10.1.3.0/24"
      "subnet-2": "10.1.4.0/24"
      }
  }

Creates multiple maps with all relevant configs grouped together
+ locals_output = {
    + public_subnet_locals = [
        + {
            + availability_zone = "us-east-1a"
            + cidr_block        = "10.1.0.0/24"
            + subnet_number     = "pubsbnt1a-1"
          },
        + {
            + availability_zone = "us-east-1b"
            + cidr_block        = "10.1.1.0/24"
            + subnet_number     = "pubsbnt1b-1"
          },
        + {
            + availability_zone = "us-east-1c"
            + cidr_block        = "10.1.3.0/24"
            + subnet_number     = "pubsbnt1c-1"
          },
        + {
            + availability_zone = "us-east-1c"
            + cidr_block        = "10.1.4.0/24"
            + subnet_number     = "pubsbnt1c-2"
          },
      ]
  }   */

locals {
  public_subnet_set = flatten([
    for selected_az, public_subnet_map in var.public_subnet_cidr_map: [
      for subnetnumber, cidrblock in public_subnet_map : {
        availability_zone = selected_az
        cidr_block = cidrblock
        subnet_number = "pubsbnt${substr(selected_az, -2, -1)}-${substr(subnetnumber, -1, -1)}"
      }
    ]
  ])
}


locals {
  private_subnet_set = flatten([
    for selected_az, private_subnet_map in var.private_subnet_cidr_map: [
      for subnetnumber, cidrblock in private_subnet_map : {
        availability_zone = selected_az
        cidr_block = cidrblock
        subnet_number = "pvtsbnt${substr(selected_az, -2, -1)}-${substr(subnetnumber, -1, -1)}"
      }
    ]
  ])
}


locals {
  public_subnet_cidr_list = flatten([
    for selected_az, public_subnet_map in var.public_subnet_cidr_map: [
      for subnet_number, subnet_cidr in public_subnet_map: subnet_cidr
      ]
    ])
}

locals {
  public_subnet_id_list = flatten([
    for subnet_name, subnet_id in local.public_subnet_name2id_map: subnet_id
    ])
}


locals {
  private_subnet_cidr_list = flatten([
    for selected_az, private_subnet_map in var.private_subnet_cidr_map: [
      for subnet_number, subnet_cidr in private_subnet_map: subnet_cidr
      ]
    ])
}

locals {
  private_subnet_id_list = flatten([
    for subnet_name, subnet_id in local.private_subnet_name2id_map: subnet_id
    ])
}


locals {
  public_subnet_name2id_map = {
    for subnetkey, subnetdetails in aws_subnet.public_subnet: subnetdetails.tags.Name => subnetdetails.id
    }
}


locals {
  private_subnet_name2id_map = {
    for subnetkey, subnetdetails in aws_subnet.private_subnet: subnetdetails.tags.Name => subnetdetails.id
    }
}