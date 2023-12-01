### Golang code for sending usage reports to Google

This code retrieves the metric value (Number of Devices) from the database and generates a json file with required content to be able to send to Google.

This code built into an golang binary and a container image is being built using Dockerfile in this directory.

We are running a kubernetes deployement with this conatiner image along with a [ubbagent reporting sidecar container](https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/master/docs/billing-integration.md#agent-deployment-and-configuration) from google.