module "bootstrap_cloudtrail" {
    source = "github.com/build-on-aws/terraform-samples//modules/bootstrap-cloudtrail"

    aws_region             = "us-west-2"
    cloudtrail_bucket_name = "bootstrap-cloudtrails-isc211"
    cloudtrail_name        = "ISC211+ Cloudtrails"
}
