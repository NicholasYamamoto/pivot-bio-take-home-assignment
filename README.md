# pivot-bio-take-home-assignment
Take-home assignment for the PivotBio - Senior Infrastructure Engineer interview.

For this assignment, I was tasked with providing Terraform scripts that will create a new AWS S3 storage bucket and configure it to send an email to a specifiable email address whenever new objects are created in the bucket.

Additionally, I was also asked to provide configuration for a solution to automatically deploy these Terraform scripts to AWS via a CI/CD tool of choice.

This assignment utilizes several useful services that AWS provides:
* Simple Storage Solution (S3)
* Simple Notification Service (SNS)
* Amazon EventBridge
* AWS Lambda

This repository is broken up into three scripts:
* [`configure-sns.tf`](https://github.com/NicholasYamamoto/pivot-bio-take-home-assignment/tree/master/configure-sns.tf)
    * Creates an AWS Key Management Service (KMS) key used to encrypt/decrypt any published SNS messages
    * Creates an Amazon EventBridge Rule and Target to capture any `Object Created` events in any existing S3 buckets
    * Creates an SNS Topic to log events defined by the EventBridge Rule
    * Creates an SNS Subscription to the SNS Topic to allow a specified email address to "subscribe" and be alerted of any new events captured under the SNS Topic

* [`create-bucket.tf`](https://github.com/NicholasYamamoto/pivot-bio-take-home-assignment/tree/master/create-bucket.tf)
    * Creates an AWS KMS key used to encrypt any objects within the S3 bucket
    * Creates a new S3 storage bucket to store any objects
    * Configures the S3 bucket to use Server-Side Encryption (SSE) to harden security
* [`create-email-lambda.tf`](https://github.com/NicholasYamamoto/pivot-bio-take-home-assignment/tree/master/create-email-lambda.tf)
    * Lorem ipsum dolar

## Design Choices
To demonstrate my knowledge of AWS, I
* Enabled and configured Server-Side Encryption (SSE) for S3, to harden security around any created storage buckets
* Created an AWS KMS key for SNS to allow encryption/decryption of published SNS messages to help obfuscate any potential sensitive/confidential data that could be included in the messages
* Created an AWS KMS key to encryptall objects within the created S3 bucket, to harden security around the contents of each S3 bucket itself
* Created a GitHub Actions pipeline to deploy the S3 bucket (with SNS configuration) to AWS

Typically, when Terraform is integrated with GitHub Actions in a project, the values used in the Terraform script execution are passed either by using a `.tfvars` file, or are configured and set within the GitHub Actions `yml` script itself in `.github/workflows`.

However, I wanted to make this process as simplified and "self-service" as possible, and eliminate the need to open a new PR in order to specify the email address the SNS topic will send published events to. Rather than using a "hard-coded" value for this, I implemented an input prompt in the GitHub Action workflow to allow the user to specify the email address dynamically for every deployment, which is passed to the [`create-email-lambda script`](https://github.com/NicholasYamamoto/pivot-bio-take-home-assignment/tree/master/create-email-lambda.tf) to set the