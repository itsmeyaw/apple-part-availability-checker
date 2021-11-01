# Apple Part Availability Checker
A lambda code (for AWS) that check periodically for availability of an Apple part and notify user when item available

## Deployment
1. Fork the repo
2. Configure terraforming (you can use terraform cloud or another backend, but make changes to the code accordingly)
3. Make a new IAM policy with json like in `resources/deployment-iam/iam.json` 
4. Make a new IAM user with programmatic access and attach the previously made iam policy to it
5. Set the variables needed for terraforming

## Notes
- The IAM Policy JSON is however insecure and should not used in a high productive account