import os

from troposphere import Sub, Ref, Template
from troposphere.ecs import (
    Cluster, Service, TaskDefinition,
    ContainerDefinition, NetworkConfiguration,
    AwsvpcConfiguration, PortMapping, LogConfiguration,
    Secret
)
from troposphere.iam import Role, Policy
from troposphere.logs import LogGroup

SUBNET = os.getenv('TRIPLEJPLAYS_SUBNET')
PARAM_NAMESPACE = os.getenv('TRIPLEJPLAYS_NS')

t = Template()
t.add_version('2010-09-09')

ecs_role = t.add_resource(Role(
    'TripleJPlaysEcsRole',
    AssumeRolePolicyDocument={
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ecs-tasks.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    },
    Policies=[
        Policy(
            PolicyName="AllowParameterAccess",
            PolicyDocument={
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Action": [
                            "ssm:DescribeParameters"
                        ],
                        "Resource": "*"
                    },
                    {
                        "Effect": "Allow",
                        "Action": [
                            "ssm:GetParameters"
                        ],
                        "Resource": Sub(
                            "arn:aws:ssm:${AWS::Region}:${AWS::AccountId}:parameter${ns}*",
                            ns=PARAM_NAMESPACE
                        )
                    }
                ]
            }
        )
    ]
))

cluster = t.add_resource(Cluster(
    'TripleJPlaysCluster'
))

container_logs = LogGroup(
    'TripleJPlaysLogs',
    LogGroupName='/ecs/triplejplays',
    RetentionInDays=14,
)

task_definition = t.add_resource(TaskDefinition(
    'TripleJPlaysTask',
    RequiresCompatibilities=['FARGATE'],
    Cpu='256',
    Memory='512',
    NetworkMode='awsvpc',
    Family=Sub('${AWS::StackName}${name}', name='TripleJPlays'),
    ExecutionRoleArn=Ref(ecs_role),
    ContainerDefinitions=[
        ContainerDefinition(
            Name='TripleJPlaysWA',
            Image=Sub(
                '${AWS::AccountId}.dkr.ecr.${AWS::Region}.amazonaws.com/triplejplayswa',
            ),
            Secrets=[
                Secret(
                    Name='TRIPLEJ_CONSUMER_KEY',
                    ValueFrom='{}consumer_key'.format(PARAM_NAMESPACE)
                ),
                Secret(
                    Name='TRIPLEJ_CONSUMER_SECRET',
                    ValueFrom='{}consumer_secret'.format(PARAM_NAMESPACE)
                ),
                Secret(
                    Name='TRIPLEJ_ACCESS_TOKEN',
                    ValueFrom='{}access_token'.format(PARAM_NAMESPACE)
                ),
                Secret(
                    Name='TRIPLEJ_ACCESS_TOKEN_SECRET',
                    ValueFrom='{}access_token_secret'.format(PARAM_NAMESPACE)
                ),
            ],
            Essential=True,
            LogConfiguration=LogConfiguration(
                LogDriver='awslogs',
                Options={
                    'awslogs-group': '/ecs/triplejplays',
                    'awslogs-region': 'us-west-2',
                    'awslogs-stream-prefix': 'wa'
                }  
            )
        )
    ]
))

service = t.add_resource(Service(
    'TripleJPlaysService',
    Cluster=Ref(cluster),
    DesiredCount=1,
    TaskDefinition=Ref(task_definition),
    LaunchType='FARGATE',
    NetworkConfiguration=NetworkConfiguration(
        AwsvpcConfiguration=AwsvpcConfiguration(
            Subnets=[SUBNET]
        )
    )
))

print(t.to_json())