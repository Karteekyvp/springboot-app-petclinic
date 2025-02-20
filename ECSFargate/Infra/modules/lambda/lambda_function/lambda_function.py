import json
import boto3
import os

sns_client = boto3.client('sns')

def lambda_handler(event, context):
    topic_arn = os.environ['SNS_TOPIC_ARN']
    message = "Deployment completed successfully for the Spring Boot application on ECS Fargate."
    
    response = sns_client.publish(
        TopicArn=topic_arn,
        Message=message,
        Subject="Deployment Notification"
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Notification sent!')
    }
