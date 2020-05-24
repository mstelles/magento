resource "aws_route_table" "PublicRouteTable" {
  vpc_id = "${aws_vpc.mainvpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.IGW_TF.id}"
  }
  tags = {
    Name = "PublicRouteTable"
  }
  depends_on = ["aws_vpc.mainvpc", "aws_internet_gateway.IGW_TF"]
}


resource "aws_route_table_association" "publicroutetableassociation" {
  count          = "${length(var.public_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.public_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.PublicRouteTable.id}"
  depends_on     = ["aws_subnet.public_subnets", "aws_route_table.PublicRouteTable"]
}
