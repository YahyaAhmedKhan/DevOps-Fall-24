resource "aws_instance" "amazon_linux-ec2-hw1" {
  ami                         = "ami-0453ec754f44f9a4a" # Amazon Linux 2023
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-070061a2764927c94" # Subnet ID for EC2 instance
  key_name                    = "yahya-ec2-key"
  vpc_security_group_ids      = [aws_security_group.my-sg.id] # Assign EC2 security group
  associate_public_ip_address = true
  iam_instance_profile        = "tf_ec2s3" // role made in IAM, alowed services: ec2

  tags = {
    Name = "amazon_linux-ec2-hw1"
  }

  user_data = base64encode(file("${path.module}/userdata/amazon-ec2.sh"))  # Importing user data from file

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

}
resource "aws_instance" "ubuntu-ec2-hw1" {
  ami                         = "ami-005fc0f236362e99f" # Ubuntu Server 22.04 LTS
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-070061a2764927c94" # Subnet ID for EC2 instance
  key_name                    = "yahya-ec2-key"
  vpc_security_group_ids      = [aws_security_group.my-sg.id] # Assign EC2 security group
  associate_public_ip_address = true
  iam_instance_profile        = "tf_ec2s3" // role made in IAM, alowed services: ec2

  tags = {
    Name = "ubuntu-ec2-hw1"
  }

  user_data = base64encode(file("${path.module}/userdata/ubuntu-ec2.sh"))  # Importing user data from file

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

}

