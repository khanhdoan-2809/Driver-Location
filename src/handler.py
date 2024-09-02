import boto3
from botocore.exceptions import ClientError
import json
import uuid
from datetime import date

dynamodb = boto3.client("dynamodb")
def lambda_handler(event, context):
    print(event)
    try:
        table_name = "DriverLocation"
        body_str = event['Records'][0]['body']
        body = json.loads(body_str)
        
        if not all(key in body for key in ['userID', 'latitude', 'longitude']):
            return {
                'statusCode': 400,
                'body': json.dumps('Missing required fields: userID, latitude, or longitude')
            }
        
        userID = body['userID']
        lattitude = body['latitude']
        longtitude = body['longitude']
        
        id =  str(uuid.uuid4())
        today = str(date.today())
        item = {
            "ID": {'S': id},
            "UserID": {'S': userID},
            "Latitude": {'S': lattitude},
            "Longtitude": {'S': longtitude},
            "Date": {'S': today},
            "Tag": {'S': ''}
        }
        
        dynamodb.put_item(
            TableName = table_name,
            Item = item
        )
        
        print("oke")
        return {
            'statusCode': 200,
            'body': json.dumps('Item inserted successfully')
        }
        
    except ClientError as e:
        print(str(e))
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error inserting item: {str(e)}')
        }
    
    except Exception as e:
        print(str(e))
        return {
            'statusCode': 500,
            'body': json.dumps(f'Server error: {str(e)}')
        }