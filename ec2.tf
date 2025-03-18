resource "aws_instance" "web" {
  ami                    = var.custom_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [aws_security_group.application_security_group.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name # Attach IAM profile
  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }
  # doesn't protects from accidental termination
  disable_api_termination = false

  tags = {
    Name = "web-application-instance"
  }
}
