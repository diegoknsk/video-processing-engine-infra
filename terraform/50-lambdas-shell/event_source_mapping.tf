# Event source mappings: SQS → Lambda. Orchestrator ← q-video-process; Finalizer ← q-video-zip-finalize;
# VideoManagement ← q-video-status-update (quando enable_status_update_consumer = true).
# aws_lambda_permission permite que SQS invoque a Lambda.

# --- q-video-process → LambdaVideoOrchestrator ---
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

# --- q-video-status-update → LambdaVideoManagement (quando enable_status_update_consumer) ---
resource "aws_lambda_permission" "sqs_invoke_video_management" {
  count = var.enable_status_update_consumer ? 1 : 0

  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.video_management.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = var.q_video_status_update_arn
}

resource "aws_lambda_event_source_mapping" "video_management_q_video_status_update" {
  count = var.enable_status_update_consumer ? 1 : 0

  event_source_arn = var.q_video_status_update_arn
  function_name    = aws_lambda_function.video_management.function_name
  batch_size       = 1
}
