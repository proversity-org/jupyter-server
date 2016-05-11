Resources:
  SecurityGroupIngress:
    Type: AWS::EC2::SecurityGroupIngress
    Properties:
      GroupId: {"Fn::GetAtt" : ["AWSEBSecurityGroup", "GroupId"]}
      IpProtocol: tcp
      ToPort: 3334
      FromPort: 3334
      SourceSecurityGroupName: {"Fn::GetAtt" : ["AWSEBLoadBalancer" , "SourceSecurityGroup.GroupName"]}
  SecurityGroupIngress:
    Type: AWS::EC2::SecurityGroupIngress
    Properties:
      GroupId: {"Fn::GetAtt" : ["AWSEBSecurityGroup", "GroupId"]}
      IpProtocol: tcp
      ToPort: 3335
      FromPort: 3335
      SourceSecurityGroupName: {"Fn::GetAtt" : ["AWSEBLoadBalancer" , "SourceSecurityGroup.GroupName"]}
  SecurityGroupEgress:
    Type: AWS::EC2::SecurityGroupEgress
    Properties:
      GroupId: {"Fn::GetAtt" : ["AWSEBSecurityGroup", "GroupId"]}
      IpProtocol: tcp
      ToPort: 3334
      FromPort: 3334
      SourceSecurityGroupName: {"Fn::GetAtt" : ["AWSEBLoadBalancer" , "SourceSecurityGroup.GroupName"]}
  SecurityGroupEgress:
    Type: AWS::EC2::SecurityGroupEgress
    Properties:
      GroupId: {"Fn::GetAtt" : ["AWSEBSecurityGroup", "GroupId"]}
      IpProtocol: tcp
      ToPort: 3335
      FromPort: 3335
      SourceSecurityGroupName: {"Fn::GetAtt" : ["AWSEBLoadBalancer" , "SourceSecurityGroup.GroupName"]}

