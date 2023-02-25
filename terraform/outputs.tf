//output "latest_amazon_linux_ami_id" {
  //value = data.aws_ami.latest_amazon_linux.id
//}
output "ec2_public_ip" {
    value = aws_instance.app-server.public_ip
}