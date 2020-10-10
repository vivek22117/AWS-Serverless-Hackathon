import boto3
import os
import json
import logging

LOG = logging.getLogger()
LOG.setLevel('DEBUG')

VERIFIED_EMAIL = os.environ['verified_email']
SNS_ARN = os.environ['sns_arn']

sns_client = boto3.client('sns')


def lambda_handler(event, context):
    LOG.info("event received.... ", event)

    response = {
        "body": json.dumps({"message": ""}),
        "headers": {
            "content-type": "application/json"
        },
        "statusCode": 405,
        "isBase64Encoded": False,
    }

    path, method = event.get('path'), event.get('httpMethod')
    data = event['body']

    LOG.info('Received HTTP %s request for path %s' % (method, path))

    if path == '/message' and method == 'POST':
        response["body"], response["statusCode"] = perform_operation(data)

    else:
        msg = '%s %s not allowed' % (method, path)
        response["statusCode"] = 405
        response["body"] = json.dumps({"error": msg})
        LOG.error(msg)

    return response


def perform_operation(data):
    LOG.info("Processing payload %s" % data)
    LOG.info(type(data))
    received_msg = json.loads(data)

    message = "User {} with email: {} and contact number {} " \
              "has been successfully registered".format(received_msg['username'],
                                                         received_msg['email'],
                                                         received_msg['contactnumber'])
    try:
        sns_client.publish(
            TopicArn=SNS_ARN,
            Message=message,
            MessageStructure='string'
        )
        return json.dumps({"message": "Successfully delivered!"}), 200
    except Exception as error:
        LOG.error("Something went wrong: %s" % error)
        return json.dumps({"message": str(error)}), 500
