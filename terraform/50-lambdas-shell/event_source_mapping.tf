# Event source mappings: SQS → Lambda. Orchestrator ← q-video-process (Storie-18.1); Finalizer ← q-video-zip-finalize;
# UpdateStatusVideo ← q-video-status-update (Storie-18.1).
# aws_lambda_permission permite que SQS invoque a Lambda.

# --- q-video-process → LambdaVideoOrchestrator (Storie-18.1) ---
resource "aws_lambda_permission" "sqs_invoke_orchestrator" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.video_orchestrator.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = var.q_video_process_arn
}

resource "aws_lambda_event_source_mapping" "orchestrator_q_video_process" {
  event_source_arn = var.q_video_process_arn
  function_name    = aws_lambda_function.video_orchestrator.function_name
  batch_size       = 1
}

# --- q-video-zip-finalize → LambdaVideoFinalizer ---
resource "aws_lambda_permission" "sqs_invoke_finalizer" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.video_finalizer.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = var.q_video_zip_finalize_arn
}

resource "aws_lambda_event_source_mapping" "finalizer_q_video_zip_finalize" {
  event_source_arn = var.q_video_zip_finalize_arn
  function_name    = aws_lambda_function.video_finalizer.function_name
  batch_size       = 1
}

# --- q-video-status-update → LambdaUpdateStatusVideo (Storie-18.1) ---
resource "aws_lambda_permission" "sqs_invoke_update_status_video" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_status_video.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = var.q_video_status_update_arn
}

resource "aws_lambda_event_source_mapping" "update_status_video_q_video_status_update" {
  event_source_arn = var.q_video_status_update_arn
  function_name    = aws_lambda_function.update_status_video.function_name
  batch_size       = 1
}
