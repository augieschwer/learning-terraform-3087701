resource "aws_instance" "blog" {
  ami           = "ami-785db401"
  instance_type = var.instance_type

  tags = {
    Name = "HelloWorld"
  }
}
