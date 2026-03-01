aws sts get-caller-identity

aws sns get-topic-attributes  --topic-arn arn:aws:sns:us-east-1:804879632477:video-processing-engine-dev-topic-video-submitted

aws iam simulate-principal-policy --policy-source-arn arn:aws:iam::804879632477:role/LabRole  --action-names sns:SetTopicAttributes sns:GetTopicAttributes s3:PutBucketNotification sqs:SetQueueAttributes sns:Subscribe