# AWS S3 Static Website Hosting with Terraform

This project demonstrates how to deploy a static website on AWS S3 using Terraform. The infrastructure is defined as code, allowing for repeatable and consistent deployments.

## Architecture

![AWS S3 Static Website Architecture](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/AWS%20S3%20Static%20Website%20Hosting%20with%20Terraform/Website%20Files/startbootstrap-new-age-gh-pages/Pic/1_l75N_TSW6KwF1kWmU5PI6Q.PNG)

The architecture consists of:
- Terraform for Infrastructure as Code
- AWS S3 bucket configured for static website hosting
- Website content (HTML, CSS, JS files)
- Public access configuration for the website

## Implementation Details

### 1. S3 Bucket Creation

The first part of our Terraform code creates an S3 bucket named "portfolio0-bucket" and configures it for static website hosting:

```terraform
resource "aws_s3_bucket" "Bucket" {
  bucket = "portfolio0-bucket"
  website {
    index_document = "index.html"
  }

  tags = {
    Name        = "Running Bucket"
    Environment = "Dev"
  }
}
```

This creates a bucket with:
- A unique name "portfolio0-bucket"
- Website hosting enabled with "index.html" as the default document
- Tags for organization and identification

Here's how the bucket appears in the AWS Console after creation:

![AWS S3 Bucket Creation](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/AWS%20S3%20Static%20Website%20Hosting%20with%20Terraform/Website%20Files/startbootstrap-new-age-gh-pages/Pic/Screenshot%202025-04-02%20125924.png)

### 2. Uploading Website Content

The next section of code uploads all files from the "startbootstrap-new-age-gh-pages" directory to the S3 bucket:

```terraform
resource "aws_s3_bucket_object" "files" {
  for_each = fileset("startbootstrap-new-age-gh-pages", "**")

  bucket       = aws_s3_bucket.Bucket.id
  key          = each.value
  source       = "startbootstrap-new-age-gh-pages/${each.value}"
  content_type = lookup({
    "html" = "text/html",
    "css"  = "text/css",
    "js"   = "application/javascript",
    "png"  = "image/png",
    "jpg"  = "image/jpeg",
    "jpeg" = "image/jpeg",
    "svg"  = "image/svg+xml"
  }, try(regex("\\.([^.]+)$", each.value)[0], ""), "application/octet-stream")
}
```

This resource:
- Uses Terraform's `fileset` function to find all files in the source directory
- Uploads each file to the S3 bucket with its original path
- Sets the correct content type for each file based on its extension

After deployment, the files appear in the S3 bucket:

![S3 Bucket Objects](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/AWS%20S3%20Static%20Website%20Hosting%20with%20Terraform/Website%20Files/startbootstrap-new-age-gh-pages/Pic/Screenshot%202025-04-02%20130103.png)

### 3. Configuring Public Access

To make the website publicly accessible, we need to configure the bucket's public access settings and attach a bucket policy:

```terraform
resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.Bucket.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket.Bucket]
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket     = aws_s3_bucket.Bucket.id
  policy     = <<EOF
   {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.Bucket.id}/*"
            ]
        }
    ]
}
EOF
  depends_on = [aws_s3_bucket_public_access_block.public]
}
```

These resources:
- Disable public access blocks on the bucket
- Attach a bucket policy that allows public read access to all objects
- Use `depends_on` to ensure proper creation order

### 4. Output the Website URL

Finally, the code outputs the S3 bucket name and website endpoint URL:

```terraform
output "bucket_info" {
  value = "Bucket Name: ${aws_s3_bucket.Bucket.bucket} Website URL: http://${aws_s3_bucket.Bucket.website_endpoint}"
}
```

After applying the Terraform configuration, the website is accessible at the provided URL:

![Deployed Website](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/AWS%20S3%20Static%20Website%20Hosting%20with%20Terraform/Website%20Files/startbootstrap-new-age-gh-pages/Pic/Screenshot%202025-04-02%20125238.png)

## Complete Terraform Code

```terraform
#Create an S3 bucket and upload an HTML file to it using Terraform
resource "aws_s3_bucket" "Bucket" {
  bucket = "portfolio0-bucket"
  website {
    index_document = "index.html"
  }

  tags = {
    Name        = "Running Bucket"
    Environment = "Dev"
  }
}

# #Uploading all the content of startbootstrap-new-age-gh-pages into the bucket 
resource "aws_s3_bucket_object" "files" {
  for_each = fileset("startbootstrap-new-age-gh-pages", "**")

  bucket       = aws_s3_bucket.Bucket.id
  key          = each.value
  source       = "startbootstrap-new-age-gh-pages/${each.value}"
  content_type = lookup({
    "html" = "text/html",
    "css"  = "text/css",
    "js"   = "application/javascript",
    "png"  = "image/png",
    "jpg"  = "image/jpeg",
    "jpeg" = "image/jpeg",
    "svg"  = "image/svg+xml"
  }, try(regex("\\.([^.]+)$", each.value)[0], ""), "application/octet-stream")
}


#Give public access to the bucket
resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.Bucket.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket.Bucket]
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket     = aws_s3_bucket.Bucket.id
  policy     = <<EOF
   {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.Bucket.id}/*"
            ]
        }
    ]
}
EOF
  depends_on = [aws_s3_bucket_public_access_block.public]
}

output "bucket_info" {
  value = "Bucket Name: ${aws_s3_bucket.Bucket.bucket} Website URL: http://${aws_s3_bucket.Bucket.website_endpoint}"
}
```

## Prerequisites

To use this project, you'll need:
- [Terraform](https://www.terraform.io/downloads.html) installed
- AWS account with appropriate permissions
- AWS CLI configured with credentials
- Bootstrap template or your own website files

## Usage

1. Clone this repository
2. Place your website files in the "startbootstrap-new-age-gh-pages" directory
3. Initialize Terraform:
   ```
   terraform init
   ```
4. Apply the configuration:
   ```
   terraform apply --auto-approve
   ```
5. Access your website using the URL from the output

## Notes

- This example uses a Bootstrap template, but you can use any static website files
- Remember that S3 website URLs are in the format: `http://bucket-name.s3-website-region.amazonaws.com`
