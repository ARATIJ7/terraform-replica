resource "aws_instance" "mongodb" {
  count         = var.replica_count
  ami           = "ami-06bbf0bc3c7055d18"  # Amazon Linux 2 AMI (replace with your preferred AMI)
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.subnet.id
  security_groups = [aws_security_group.mongodb_sg.name]

  tags = {
    Name = "MongoDB-${count.index + 1}"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install epel -y
              sudo yum install -y mongodb-org
              sudo systemctl start mongod
              sudo systemctl enable mongod
              
              # Configure MongoDB replication
              PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
              mongo --eval 'rs.initiate({_id: "rs0", members: [{ _id: 0, host: "'$PRIVATE_IP':27017"}]})'
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "mongodb_replicas" {
  count = var.replica_count

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.ssh_private_key_path)
      host        = aws_instance.mongodb[count.index].public_ip
    }

    inline = [
      "sleep 60",
      "mongo --eval 'rs.add(\"${aws_instance.mongodb[count.index].private_ip}:27017\")'",
    ]
  }

  depends_on = [aws_instance.mongodb]
}
