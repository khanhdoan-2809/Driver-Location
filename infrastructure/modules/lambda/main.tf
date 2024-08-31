data "archive_file" "lambda_archive" {
  source_dir    = "${path.root}../../../src"
  output_path   = "${path.root}../../../src/lambda-archive.zip"
  type          = "zip"
}

resource "aws_lambda_function" "lambda_sqs" {
    function_name       = "lambda-sqs"
    handler             = "handler.lambda_handler"
    role                = var.mv_lambda_role
    runtime             = "python3.11"

    filename            = data.archive_file.lambda_archive.output_path
    source_code_hash    = data.archive_file.lambda_archive.output_base64sha256 # code hash of package , to detect code changes in the code to trigger a redeployment

    timeout             = 30
    memory_size         = 128

    
    depends_on = [var.mv_lambda_role_policy]
}

# permission sqs to lambda
resource "aws_lambda_permission" "allows_sqs_to_trigger_lambda" {
    statement_id  = "AllowExecutionFromSQS"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda_sqs.function_name
    principal     = "sqs.amazonaws.com"
    source_arn    = var.mv_sqs_arn
}

# Trigger lambda on message to SQS
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size       = 1 # The largest number of records that Lambda will retrieve from event source at the time of invocation.
  event_source_arn = var.mv_sqs_arn
  enabled          = true
  function_name    = aws_lambda_function.lambda_sqs.arn
}