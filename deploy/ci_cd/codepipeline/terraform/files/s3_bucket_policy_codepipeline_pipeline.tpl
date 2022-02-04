{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "codepipeline",
            "Effect":"Allow",
            "Principal": {
                "Service": [
                    "codepipeline.amazonaws.com"
                ]
            },
            "Action":[
                "s3:*"
            ],
            "Resource": [
                "${resource_arn}"
            ]
        }
    ]
}