resource "aws_instance" "varnish" {
  #count = "${length(var.public_subnet_cidr)}"
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.ec2_public_security_group.id}"]
  #subnet_id = "${aws_subnet.public_subnets[count.index].id}"
  subnet_id = "${aws_subnet.public_subnets[0].id}"
  key_name  = "frankfurt"
  tags = {
    Name = "Varnish"
    #Name = "${format("Varnish-%d", count.index+1)}"
  }
  user_data  = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y varnish
    mv /etc/varnish/default.vcl /etc/varnish/default-orig.vcl
    echo "vcl 4.0;
    backend default {
        .host = "${aws_instance.magento.public_dns}";
        .port = "80";
    }
    sub vcl_recv {
    }
    sub vcl_backend_response {
    }
    sub vcl_deliver {
    }" >> /etc/varnish/default.vcl
    systemctl start varnish.service
    systemctl enable varnish.service
    EOF
  depends_on = ["aws_vpc.mainvpc", "aws_subnet.public_subnets", "aws_security_group.ec2_public_security_group"]
}

resource "aws_instance" "magento" {
  #count = "${length(var.public_subnet_cidr)}"
  ami                    = "${var.ami}"
  instance_type          = "t2.medium"
  vpc_security_group_ids = ["${aws_security_group.ec2_public_security_group.id}"]
  subnet_id              = "${aws_subnet.public_subnets[1].id}"
  key_name               = "frankfurt"
  tags = {
    Name = "Magento"
    #Name = "${format("Magento-%d", count.index+1)}"
  }
  user_data  = <<-EOF
    #! /bin/bash
    curl -o /tmp/magento_preinstall.sh https://raw.githubusercontent.com/mstelles/magento/master/magento_preinstall.sh
    if -f [ "$?" == "0" ]; then
      bash -x /tmp/magento_preinstall.sh
      echo "installing magento"
      useradd -m -c "Magento 2" magento
      export COMPOSER_HOME="/root/.config/composer"
      curl -q -o /tmp/auth.json https://raw.githubusercontent.com/mstelles/magento/master/auth.json
      mkdir /root/.composer
      cp /tmp/auth.json /root/.composer
      cd /var/www/html
      curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/bin --filename=composer
      composer create-project --repository=https://repo.magento.com/ magento/project-community-edition magento2
      cd /var/www/html/magento2
      find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
      find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
      chown -R magento:www-data .
      chmod u+x bin/magento
      bin/magento setup:install --base-url=https://${aws_alb.magentoalb.dns_name}/ --db-host=localhost --db-  name=magento --db-user=magento --db-password=magento --admin-firstname=admin --admin-lastname=admin --  admin-email=admin@admin.com --admin-user=admin --admin-password=admin123 --language=en_US --currency=USD -  -timezone=Africa/Johannesburg --use-rewrites=1
    else
      echo "Couldn't download pre-install script. Exiting"
    fi
    echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/test.html
    echo "ALB: ${aws_alb.magentoalb.dns_name}" | sudo tee -a /var/www/html/test.html
    rm /tmp/auth.json
    EOF
  depends_on = ["aws_vpc.mainvpc", "aws_subnet.public_subnets", "aws_security_group.ec2_public_security_group"]
}
