# Amazon CloudFormation Delinea Secret Server Integration

Amazon CloudFormation is managed using AWS Identity and Access Management tools, documentation can be found [here](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-iam-template.html)

To discover and manage these accounts you should implement the [AWS IAM Users discovery and password changing tools](/Scripts/SecretServer/AWS/AWS-IAM%20Users/).  Scanning for the  `arn:aws:iam::aws:policy/AWSCloudFormationFullAccess
` ARN along with any other specific ARNS needed.


# Disclaimer

The provided scripts are for informational purposes only and are not intended to be used for any production or commercial purposes. You are responsible for ensuring that the scripts are compatible with your system and that you have the necessary permissions to run them. The provided scripts are not guaranteed to be error-free or to function as intended. The end user is responsible for testing the scripts thoroughly before using them in any environment. The authors of the scripts are not responsible for any damages or losses that may result from the use of the scripts. The end user agrees to use the provided scripts at their own risk. Please note that the provided scripts may be subject to change without notice.