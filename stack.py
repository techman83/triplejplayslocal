import os

from troposphere import Sub, Ref, Template
from troposphere.ecs import (
    Cluster, Service, TaskDefinition,
    ContainerDefinition, NetworkConfiguration,
    AwsvpcConfiguration, LogConfiguration, Secret,
    Environment
)
from troposphere.iam import Role, Policy
from troposphere.logs import LogGroup

SUBNETS = os.getenv('TRIPLEJPLAYS_SUBNETS').split(' ')
PARAM_NAMESPACE = '/triplejplays/'

t = Template()
t.add_version('2010-09-09')

ecs_role = t.add_resource(Role(
    'TripleJPlaysExecutionRole',
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
    ],
    ManagedPolicyArns=[
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    ],
))

cluster = t.add_resource(Cluster(
    'TripleJPlaysCluster'
))

t.add_resource(LogGroup(
    'TripleJPlaysLogs',
    LogGroupName='/ecs/triplejplays',
    RetentionInDays=14,
))

task_definition = TaskDefinition(
    'TripleJPlaysTask',
    RequiresCompatibilities=['FARGATE'],
    Cpu='256',
    Memory='512',
    NetworkMode='awsvpc',
    Family=Sub('${AWS::StackName}${name}', name='TripleJPlays'),
    ExecutionRoleArn=Ref(ecs_role),
    ContainerDefinitions=[]
)

timezones = [
    {'location': 'wa', 'tz': 'Australia/Perth'},
    {'location': 'sa', 'tz': 'Australia/Adelaide'},
]

for timezone in timezones:
    location = timezone['location']
    task_definition.ContainerDefinitions.append(
        ContainerDefinition(
            Name='TripleJPlays{}'.format(location.upper()),
            Image=Sub(
                '${AWS::AccountId}.dkr.ecr.${AWS::Region}.amazonaws.com/triplejplayswa',
            ),
            Environment=[
                Environment(
                    Name='TZ', Value=timezone['tz']
                )
            ],
            Secrets=[
                Secret(
                    Name='TRIPLEJ_CONSUMER_KEY',
                    ValueFrom='{}{}/consumer_key'.format(PARAM_NAMESPACE, location)
                ),
                Secret(
                    Name='TRIPLEJ_CONSUMER_SECRET',
                    ValueFrom='{}{}/consumer_secret'.format(PARAM_NAMESPACE, location)
                ),
                Secret(
                    Name='TRIPLEJ_ACCESS_TOKEN',
                    ValueFrom='{}{}/access_token'.format(PARAM_NAMESPACE, location)
                ),
                Secret(
                    Name='TRIPLEJ_ACCESS_TOKEN_SECRET',
                    ValueFrom='{}{}/access_token_secret'.format(PARAM_NAMESPACE, location)
                ),
            ],
            Essential=True,
            LogConfiguration=LogConfiguration(
                LogDriver='awslogs',
                Options={
                    'awslogs-group': '/ecs/triplejplays',
                    'awslogs-region': 'us-west-2',
                    'awslogs-stream-prefix': location
                }
            )
        )
    )

t.add_resource(task_definition)

service = t.add_resource(Service(
    'TripleJPlaysService',
    Cluster=Ref(cluster),
    DesiredCount=1,
    TaskDefinition=Ref(task_definition),
    LaunchType='FARGATE',
    NetworkConfiguration=NetworkConfiguration(
        AwsvpcConfiguration=AwsvpcConfiguration(
            AssignPublicIp="ENABLED",
            Subnets=SUBNETS
        )
    )
))

print(t.to_json())
