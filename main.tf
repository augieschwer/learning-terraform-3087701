resource "aws_instance" "web" {
  ami           = "ami-785db401"
  instance_type = var.instance_type

  tags = {
    Name = "HelloWorld"
  }
}
