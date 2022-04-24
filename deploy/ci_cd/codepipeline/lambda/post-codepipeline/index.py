import boto3

client = boto3.client('codepipeline')

def post_action_fail(params):
    print('post_action_fail')

    response = client.put_job_failure_result(
        jobId = params.job,
        failureDetails = {
            'type': 'JobFailed',
            'message': params['message'],
            'externalExecutionId': params['externalExecutionId']
        }
    )

def post_action_success(params):
    print('post_action_success')

    response = client.put_job_success_result(
        jobId = params['job']
    )
    return True

def handler(event, context): 
    print("post action here")
    print("event details")
    print(event)

    try:
        return post_action_success({
            "job": event["CodePipeline.job"]['id']
        })
    
    except Exception as e:
        post_action_fail({
            "job": event["CodePipeline.job"]['id'],
            "message": str(e),
            "externalExecutionId": context.aws_request_id
        })
        return False