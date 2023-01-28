#!bin/bash
apt-get update
apt-get install -y python-setuptools
mkdir -p /opt/aws/bin
apt-get install -y wget
wget https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-py3-latest.tar.gz
python3 -m easy_install --script-dir /opt/aws/bin aws-cfn-bootstrap-py3-latest.tar.gz
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O /tmp/amazon-cloudwatch-agent.deb
dpkg -i /tmp/amazon-cloudwatch-agent.deb
/opt/aws/bin/cfn-init -v --stack ${AWS::StackId} --resource EC2 --region ${AWS::Region} --configsets default
/opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackId} --resource EC2 --region ${AWS::Region}
