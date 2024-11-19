resource "aws_instance" "web" {
  ami           = "ami-785db401"
  instance_type = "t3.nano"

  tags = {
    Name = "HelloWorld"
  }
}
