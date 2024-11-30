resource "aws_instance" "my-ec2" {
  ami                         = "ami-0453ec754f44f9a4a" # amazon 2023
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-070061a2764927c94" # Subnet ID for EC2 instance
  key_name                    = "yahya-ec2-key"
  vpc_security_group_ids      = [aws_security_group.my-sg.id] # Assign EC2 security group
  associate_public_ip_address = true
  iam_instance_profile        = "tf_ec2s3"

  tags = {
    Name = "my-ec2"
  }

  user_data = base64encode(file("${path.module}/userdata/website.sh"))  # Importing user data from file

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

}

