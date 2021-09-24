data "aws_availability_zones" "available" {}

# define AMI
data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"]
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }
}
        
resource "aws_key_pair" "my_aws_key" {
#    key_name = var.KEY
    key_name = "my_aws_key"
    public_key = file(var.PATH_TO_PUBLIC_KEY)
}

# define autoscaling launch configuration 
resource "aws_launch_configuration" "custom-launch-config" { 
    name = "custom-launch-config" 
    image_id = data.aws_ami.ubuntu.id 
    instance_type = "t2.micro"
#    key_name = var.KEY   # SSH KEY
    key_name = aws_key_pair.my_aws_key.key_name
    security_groups = [aws_security_group.custom-instance-sg.id]

    user_data = "#!/bin/bash\napt-get update\napt-get -y install net-tools nginx\nMYIP=`ifconfig | grep -E '(inet addr:172)' | awk '{ print $2 }' | cut -d ':' -f 2`\necho 'Hello Team\nThis is my IP: '$MYIP > /var/www/html/index.html"
    
    lifecycle {
      create_before_destroy =true
    }
} 

# define autoscaling group 
resource "aws_autoscaling_group" "custom-group-autoscaling" {
    name = "custom-group-autoscaling"
    vpc_zone_identifier = [aws_subnet.customvpc-public-1.id,aws_subnet.customvpc-public-2.id]
#    vpc_zone_identifier = [aws_subnet.customvpc-public-1.id]
    launch_configuration = aws_launch_configuration.custom-launch-config.name
    min_size = 2
    max_size = 4
    health_check_grace_period = 100
    health_check_type = "ELB"
    load_balancers = [aws_elb.custom-elb.name]
    force_delete = true
    tag {
        key = "Name"
        value = "custom_ec2_instance"
        propagate_at_launch = true
    }
}

output "elb" {
    value = aws_elb.custom-elb.dns_name
}

# define autoscaling configuration policy 
resource "aws_autoscaling_policy" "custom-cpu-policy" {
    name = "custom-cpu-policy"
    autoscaling_group_name = aws_autoscaling_group.custom-group-autoscaling.name
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = 1
    cooldown = 60
    policy_type = "SimpleScaling"
}

# define cloud watch monitoring 
resource "aws_cloudwatch_metric_alarm" "custom-cpu-alarm" {
    alarm_name = "custom-cpu-alarm"
    alarm_description = "alarm once cpu usage increases"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = 120
    statistic = "Average"
    threshold = 20

    dimensions = {
        "AutoScalingGroupName": aws_autoscaling_group.custom-group-autoscaling.name
    }
    actions_enabled = true
    alarm_actions = [aws_autoscaling_policy.custom-cpu-policy.arn]
}

# Define auto descaling policy 
resource "aws_autoscaling_policy" "custom-cpu-policy-scaledown" {
    name = "custom-cpu-policy-scaledown"
    autoscaling_group_name = aws_autoscaling_group.custom-group-autoscaling.name
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = -1
    cooldown = 60
    policy_type = "SimpleScaling"
}

# Define descaling cloud watch 
resource "aws_cloudwatch_metric_alarm" "custom-cpu-alarm-scaledown" {
    alarm_name = "custom-cpu-alarm-scaledown"
    alarm_description = "alarm once cpu usage decreases"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = 120
    statistic = "Average"
    threshold = 10

    dimensions = {
        "AutoScalingGroupName": aws_autoscaling_group.custom-group-autoscaling.name
    }
    actions_enabled = true
    alarm_actions = [aws_autoscaling_policy.custom-cpu-policy-scaledown.arn]
}