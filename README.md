[![Deploy a new S3 bucket with S3 Event Notifications configured.](https://github.com/NicholasYamamoto/pivot-bio-take-home-assignment/actions/workflows/deploy_new_bucket.yml/badge.svg?event=status)](https://github.com/NicholasYamamoto/pivot-bio-take-home-assignment/actions/workflows/deploy_new_bucket.yml)
# Pivot Bio Take-Home Assignment - Senior Cloud Infrastructure Engineer interview
Take-home assignment for the Pivot Bio - Senior Infrastructure Engineer interview.

For this assignment, I was tasked with providing Terraform scripts that will create a new AWS S3 storage bucket and configure it to send an email to a specifiable email address whenever new objects are created in the bucket.

Additionally, I was also asked to provide configuration for a solution to automatically deploy these Terraform scripts to AWS via a CI/CD tool of choice.

This assignment utilizes several useful services that AWS provides:
* Amazon Simple Storage Solution (S3)
* Amazon Simple Notification Service (SNS)
* Amazon CloudWatch/EventBridge
* Amazon Key Management Service (KMS)
* Amazon Identity and Access Management (IAM)

For the CI/CD pipeline, I decided to use GitHub Actions for its implementation.

This repository is broken up into three scripts:
* [`create-bucket.tf`](https://github.com/NicholasYamamoto/pivot-bio-take-home-assignment/tree/master/create-bucket.tf)
    * Creates a new S3 storage bucket to store any objects
    * Creates an AWS KMS key used to encrypt any objects within the S3 bucket
    * Configures the S3 bucket to use Server-Side Encryption (SSE) by default in order to harden security

* [`configure-sns.tf`](https://github.com/NicholasYamamoto/pivot-bio-take-home-assignment/tree/master/configure-sns.tf)
    * Creates an Amazon EventBridge Rule and Target to capture any `Object Created` events in any created S3 buckets
    * Creates an SNS Topic to log events defined by the EventBridge Event Rule
    * Creates an SNS Subscription to the SNS Topic to allow a specified email address to "subscribe" and be alerted of any events captured under the SNS Topic

* [`deploy_new_bucket.yml`](https://github.com/NicholasYamamoto/pivot-bio-take-home-assignment/tree/master/.github/workflows/deploy_new_bucket.yml)
    * Configures a GitHub Actions CI/CD pipeline that will
      * Allow for user input to set the name of the created S3 bucket (`bucket_name`) and the email address used to push S3 Alert Notifications to via SNS (`sns_email_address`)
      * Execute the following Terraform commands to initialize, lint, validate, and deploy the resources to AWS
        * `terraform init`
        * `terraform fmt`
        * `terraform validate`
        * `terraform apply`

# Design Choices
To demonstrate my knowledge of AWS, I applied a few more "upgraded" techniques when configuring the cloud infrastructure, such as:
* Enabled and configured Server-Side Encryption (SSE) for S3, to harden security around any created storage buckets
* Decided to implement the S3 Object Creation event notification using Amazon CloudWatch/EventBridge rather than setting up a simple S3 Event Notification, to demonstrate my familiarity with the more in-depth functionality of CloudWatch/EventBridge for any future work
* Created an AWS KMS key to encrypt all objects within the created S3 bucket, to harden security around the contents of each S3 bucket itself
* Created a GitHub Actions pipeline to deploy the S3 bucket (with SNS configuration) to AWS, to promote a full CI/CD software lifecycle

## Simplifying the deployment process with GitHub Actions
Typically, when Terraform is integrated with GitHub Actions in a project, the values used in the Terraform script execution are passed either by using a `.tfvars` file, or are configured and set within the GitHub Actions `yml` script itself in `.github/workflows`.

However, I wanted to make this process as simplified and "self-service" as possible, and eliminate the need for a user to open a new PR in order to specify the email address the SNS topic will send published events to. Rather than using a "hard-coded" value for this, I implemented an input prompt in the GitHub Actions workflow to allow the user to specify a `bucket_name` and `sns_email_address` for every deployment, which is passed to the Terraform scripts to configure the variables listed in [`variables.tf`](https://github.com/NicholasYamamoto/pivot-bio-take-home-assignment/tree/master/variables.tf).