resource "aws_vpc" "mainvpc" {
  cidr_block           = "${var.vpc_cidr}"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "VPC_TF"
  }

}
resource "aws_internet_gateway" "IGW_TF" {
  vpc_id = "${aws_vpc.mainvpc.id}"

  tags = {
    Name = "IGW_TF"
  }
  depends_on = ["aws_vpc.mainvpc"]
}
