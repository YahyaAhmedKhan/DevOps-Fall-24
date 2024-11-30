resource "aws_instance" "my-ec2" {
  ami                         = "ami-005fc0f236362e99f" # Amazon Linux 2023 AMI ID
  instance_type               = "t2.mico"
  subnet_id                   = "subnet-070061a2764927c94" # Subnet ID for EC2 instance
  key_name                    = ""
  vpc_security_group_ids      = [aws_security_group.my-sg.id] # Assign EC2 security group
  associate_public_ip_address = true

  tags = {
    Name = "yahyatf"
  }

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

}
