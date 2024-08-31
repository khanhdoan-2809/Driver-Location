import json

def lambda_handler(event, context):

    response = {}
    print(event)
    print(context)

    statusCode = 200
    response["statusCode"] = statusCode
    response["body"] = json.dumps(event)

    return response