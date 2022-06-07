# Observability pattern for Java/JMX applications with Amazon EKS and Observability services

This example demonstrates how to use the Amazon EKS Blueprints for Terraform a
new Amazon EKS Cluster with AWS Distro for OpenTelemetry (ADOT) configured to
specifically monitor Java/JMX applications Prometheus metrics.
The ADOT collector deployed as a Kubernetes Operator, sends metrics to a
provided Amazon Managed Prometheus workspace, to be visualize with
Amazon Managed Grafana.

This example provides a curated dashboard along with Alerts and Rules on
Amazon Managed Prometheus configured as a default data source on Managed Grafana.

---

**NOTE**

For the sake of simplicity in this example, we store sensitive information and
credentials in `dev.tfvars`. This should not be done in a production environment.
Instead, use an external secret store such as AWS Secrets Manager and use the
[aws_secretsmanager_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) data source to retrieve them.

---

## How to Deploy

### Prerequisites

- Terraform
- An AWS Account
- kubectl
- awscli
- jq
- An existing Amazon Managed Grafana workspace.

#### Generate a Grafana API Key

- Give admin access to the SSO user you set up when creating the Amazon Managed Grafana Workspace:
  - In the AWS Console, navigate to Amazon Grafana. In the left navigation bar, click **All workspaces**, then click on the workspace name you are using for this example.
  - Under **Authentication** within **AWS Single Sign-On (SSO)**, click **Configure users and user groups**
  - Check the box next to the SSO user you created and click **Make admin**
- Navigate back to the Grafana Dashboard. If you don't see the gear icon in the left navigation bar, log out and log back in.
- Click on the gear icon, then click on the **API keys** tab.
- Click **Add API key**, fill in the _Key name_ field and select _Admin_ as the Role.
- Copy your API key into `dev.tfvars` under `grafana_api_key`
- Add your Grafana endpoint to `dev.tfvars` under `grafana_endpoint`. (ex `https://<workspace-id>.grafana-workspace.<region>.amazonaws.com/`)

### Deployment Steps

- Clone this repository:

```
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

- Initialize a working directory

```
cd examples/observability/eks-java-jmx
terraform init
```

- Fill-in the values for the variables in `dev.tfvars`
- Verify the resources created by this execution:

```
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform validate
terraform plan -var-file=dev.tfvars
```

- Deploy resources:

```
terraform apply -var-file=dev.tfvars --auto-approve
```

- Add the cluster to your kubeconfig:

```
aws eks --region $AWS_REGION update-kubeconfig --name aws001-preprod-observability-eks
```

`terraform apply` will provision all the aforementioned resources.

---

**NOTE**

This example deploy all the necessary components to start monitoring your Java-based
applications. However, you can follow the steps below to build and deploy and example
application.

---

#### Verify that the Resources Deployed Successfully

- Verify that Amazon Managed Prometheus workspace was created successfully:

  - Check the status of Amazon Managed Prometheus workspace through the AWS console.

- Check that OpenTelemetry Collector is running successfully inside EKS:

```
kubectl get pods -A

NAMESPACE                       NAME                                                         READY   STATUS    RESTARTS   AGE
cert-manager                    cert-manager-7989877dff-jxk57                                1/1     Running   0          160m
cert-manager                    cert-manager-cainjector-7d55bf8f78-jcc6d                     1/1     Running   0          160m
cert-manager                    cert-manager-webhook-577f77586f-m6mlg                        1/1     Running   0          160m
kube-system                     aws-node-kvbdl                                               1/1     Running   0          3h36m
kube-system                     aws-node-lv4g4                                               1/1     Running   0          3h36m
kube-system                     aws-node-x8zcs                                               1/1     Running   0          3h36m
kube-system                     coredns-745979c988-bhtx6                                     1/1     Running   0          3h42m
kube-system                     coredns-745979c988-ktdlg                                     1/1     Running   0          3h42m
kube-system                     kube-proxy-2wqr2                                             1/1     Running   0          3h36m
kube-system                     kube-proxy-7kz4p                                             1/1     Running   0          3h36m
kube-system                     kube-proxy-rxkp8                                             1/1     Running   0          3h36m
opentelemetry-operator-system   adot-collector-64c8b46888-q6s98                              1/1     Running   0          158m
opentelemetry-operator-system   opentelemetry-operator-controller-manager-68f5b47944-pv6x7   2/2     Running   0          158m
```

- Open your Managed Grafana Workspace, head to the configuration page and and verify that Amazon Managed Prometheus was added as a default data source, test its connectivity.

#### Deploy an Example Application

In this section we will reuse an example from the AWS OpenTelemetry collector [repository](https://github.com/aws-observability/aws-otel-collector/blob/main/docs/developers/container-insights-eks-jmx.md). For convenience, the steps can be found below.

- 1. Clone [this repository](https://github.com/aws-observability/aws-otel-test-framework) and navigate to the `sample-apps/jmx/` directory.

- 2. Authenticate to Amazon ECR

```
export AWS_ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text`
export AWS_REGION={region}
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

- 3. Create an Amazon ECR repository

```
aws ecr create-repository --repository-name prometheus-sample-tomcat-jmx \
 --image-scanning-configuration scanOnPush=true \
 --region $AWS_REGION

```

- 4. Build Docker image and push to ECR.

```
docker build -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/prometheus-sample-tomcat-jmx:latest .
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/prometheus-sample-tomcat-jmx:latest
```

- 5. Install sample application

```
export SAMPLE_TRAFFIC_NAMESPACE=javajmx-sample
curl https://raw.githubusercontent.com/aws-observability/aws-otel-test-framework/terraform/sample-apps/jmx/examples/prometheus-metrics-sample.yaml > metrics-sample.yaml
sed -i .bak "s/{{aws_account_id}}/$AWS_ACCOUNT_ID/g" metrics-sample.yaml
sed -i .bak "s/{{region}}/$AWS_REGION/g" metrics-sample.yaml
sed -i .bak "s/{{namespace}}/$SAMPLE_TRAFFIC_NAMESPACE/g" metrics-sample.yaml
rm -f \*.bak
kubectl apply -f metrics-sample.yaml
```

Verify that the sample application is running:

```
kubectl get pods -n $SAMPLE_TRAFFIC_NAMESPACE

NAME                              READY   STATUS              RESTARTS   AGE
tomcat-bad-traffic-generator      1/1     Running             0          11s
tomcat-example-7958666589-2q755   0/1     ContainerCreating   0          11s
tomcat-traffic-generator          1/1     Running             0          11s
```

#### Vizualize the Application's dashboard

Log back into your Managed Grafana Workspace and navigate to the dashboard side panel, click on `Observability` Folder and open the `Sample Java/JMX Dashboard for Kubernetes` Dashboard.

<img width="1468" alt="java-dashboard" src="https://user-images.githubusercontent.com/10175027/159924937-51514e4e-3442-40a2-a921-950d69f372b4.png">

## Cleanup

- Run `terraform destroy -var-file=dev.tfvars` to remove all resources except for your Amazon Managed Grafana workspace.
- Delete your Amazon Managed Grafana workspace through the AWS console.

## Troubleshooting

- When running `terraform apply` or `terraform destroy`, the process will sometimes time-out. If that happens, run the command again and the operation will continue where it left off.

- You can explore the OpenTelemtry Collector logs by running the following command:

```
kubectl get pods -n opentelemetry-operator-system
kubectl logs -f -n opentelemetry-operator-system adot-collector-xxxx
```
