resource "aws_subnet" "public_subnets" {
  count                   = "${length(var.public_subnet_cidr)}"
  vpc_id                  = "${aws_vpc.mainvpc.id}"
  cidr_block              = "${element(var.public_subnet_cidr, count.index)}"
  availability_zone       = "${element(var.availability_zone, count.index)}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${element(var.public_subnet_names, count.index)}"
  }
  depends_on = ["aws_vpc.mainvpc"]
}
