import json
import logging
import boto3
import csv

logger = logging.getLogger()
logger.setLevel(logging.INFO)
s3_client = boto3.client ("s3")
dynamodb = boto3.resource ('dynamodb')
table = dynamodb.Table ('records')
def lambda_handler(event, context):

    logger.info('the logs is here')
    bucket_name = event ['Records'][0]['s3']['bucket']['name']
    s3_file_name = event ['Records'][0]['s3']['object']['key']
    resp = s3_client.get_object ( Bucket = bucket_name , Key = s3_file_name)
    data = resp ['Body'].read().decode ("utf-8")
    records=data.split("\n")
    for emp in records:
        print (emp)
        emp_data = emp.split(",")
        #Adding to DB
        try:
            
            table.put_item(
            Item = {
                "UserID"   : emp_data[0],
                "UserName" : emp_data[1],
                "Designation" : emp_data[2],
                "Location"  : emp_data[3]
                            }
            )
        except Exception as e:
            print ("Getting this messages means try blocked has failed")
    print ('CVS file uploaded to DynamoDB')
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
