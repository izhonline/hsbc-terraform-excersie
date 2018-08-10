Solution break down to the exercises provided:

Q1:

1.  We would like to be able to run the same stack closer to our customers in the US. Please build the same stack in
    the us-east-1 (Virginia) region. Note that Virginia has a different number of availability zones which we would like
    to take advantage of. As for a CIDR block for the VPC use whatever you feel like, providing it's compliant with RFC-1918 and does not overlap with the dublin network.

Solution 1:
The variables.tf file has now been simplified with the removal of explicit cidr_block declaration.
instead a new subnets variable has been introduced with a list "type"
variable "subnets" {
type = "list"
}

This now allows a virginia.tfvars file to be created with reference to available availability zones.. this is now able render new instances using the "count" method.

we are now able to run the US instance with: terraform apply -var-file=virginia.tfvars

Q2:

2.  The EC2 instance running Nginx went down over the weekend and we had an outage, it's been decided that we need a solution
    that is more resilient than just a single instance. Please implement a solution that you'd be confident would continue
    to run in the event one instance goes down.

Solution 2:

Simple solution to this is render additional instances in the available availability_zones by implementing the "count" method. In this solution instances were created for all avs, however we could have just indicated a static number.
