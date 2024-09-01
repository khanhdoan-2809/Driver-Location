provider "aws" {
  alias  = "main"
  region = "ap-southeast-1"
}

provider "aws" {
  alias  = "alt"
  region = "us-east-2"
}

resource "aws_dynamodb_table" "driver_location" {
  provider          = aws.main
  name              = "DriverLocation"
  billing_mode      = "PROVISIONED"
  read_capacity     = 10
  write_capacity    = 10
  hash_key          = "ID" # parition key
  range_key         = "Date" # sort key

  attribute {
   name = "ID"
   type = "N"
 }

  attribute {
   name = "UserID"
   type = "N"
 }

 attribute {
   name = "Latitude"
   type = "S"
 }

 attribute {
   name = "Longtitude"
   type = "S"
 }

 attribute {
   name = "Date"
   type = "S"
 }

 global_secondary_index {
   name                 = "PositionIndex"
   hash_key             = "Latitude"
   range_key            = "Longtitude"
   write_capacity       = 10
   read_capacity        = 10
   projection_type      = "ALL"
 }

 local_secondary_index {
    name        = "UserIDIndex"
    range_key   = "UserID"

    projection_type     = "INCLUDE"
    non_key_attributes  = ["Latitude", "Longtitude"]
 } 

 stream_enabled = true
 stream_view_type = "NEW_AND_OLD_IMAGES" # write entire before and after changing to stream
}