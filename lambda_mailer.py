import json
import urllib.parse
import boto3

print('Loading function')

sns = boto3.client('sns')
snsArn = 'arn:aws:sns:us-east-2:654577565718:s3-alert-notifications'
message = "This is a test notification."

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))

    try:
        response = sns.publish(
            TopicArn = snsArn,
            Message = message,
            Subject='Hello'
        )
        print(response)
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e
              