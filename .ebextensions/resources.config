Resources:
  AWSEBSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: "Security group to allow HTTP, SSH, and Sifu and Jupyter Notebooks"
      SecurityGroupIngress:
        - {CidrIp: "0.0.0.0/0", IpProtocol: "tcp", FromPort: 3335, ToPort: 3335}
        - {CidrIp: "0.0.0.0/0", IpProtocol: "tcp", FromPort: 3334, ToPort: 3334}
        - {CidrIp: "0.0.0.0/0", IpProtocol: "tcp", FromPort: 80, ToPort: 80}
        - {CidrIp: "0.0.0.0/0", IpProtocol: "tcp", FromPort: 22, ToPort: 22}
