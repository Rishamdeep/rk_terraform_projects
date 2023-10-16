# EC2 instances behind Auto Scaling Group, ALB, Scaling Policy, Ami building


## Steps
## Prerequisites: Create VPC and two public subnets (or use existing one)
1. Launch EC2 instance with user data script "example.sh"and connect to web service.
2. Create a custom AMI from the EC2 instance launched in step 1
3. Configure Application Load Balancer
4. Create a security group for the instances created to use.
5. Create launch template
6. Set Auto Scaling Group
a. Select launch template, VPC,& the 2 Subnets. 
b. Select the existing load balancer and target group for your load balancer.
c. Configure group size. Specify Desired capacity and Minimum capacity as 1 and Maximum capacity as 2. This deploys 1 ec2 instance as the desired capacity is set to 1.
d. Set the scaling policy for Auto Scaling Group.  Select Target tracking scaling policy and type 10 in Target value. 

## Note:
Scaling policy's baseline has been set to 10% CPU utilization for each instance.
- 1. If the average CPU utilization of an instance is less than 10%, the number of instances will be reduced.
- 2. If the average CPU utilization of an instance is over 10%, Additional instances will be deployed, load will be distributed, and adjusted to ensure that the average CPU utilization of the instances is 10%.

## How to test the setup?
Run "terraform apply" to deploy the resources. Wait for few minutes to create the ami. Copy the "alb_hostname" value from the output.

1. Check web service and load balancer: Open a new tab in your web browser and paste the DNS name of the load balancer. Web service should be working. You can see that the web instance placed in ta particular AZ is running this web page.
2. Test if Auto Scaling works: On the web page above, click the LOAD TEST menu. The web page changes and the applied load is visible.
3. Enter Auto Scaling Groups from the left side menu of the EC2 console and click the Monitoring tab. Under Enabled metrics, click EC2 and set the right time frame to 1 hour. If you wait for a few seconds, you'll see the CPU Utilization (Percent) graph changes.
4. Wait for about 5 minutes (300 seconds) and click the Activity tab to see the additional EC2 instances deployed according to the scaling policy.
5. When you click on the Instance management tab, you can see that one additional instance have sprung up (maximum capacity is set to 2)and a total of two are up and running (maximum capacity is set to 2).
6. If you use the ALB DNS that you copied earlier to access and refresh the web page, you can see that it is hosting the web page in two instances that were not there before. The current CPU load is 0% because it is a new instance. It can also be seen that each of them was created in a different availability zone.