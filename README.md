```markdown
# Kafka Data Shipper Pipeline

This project is a complete, end-to-end data pipeline created as a DevOps home assignment. It demonstrates a robust system for shipping data from a MySQL database to a Kafka cluster and back, all deployed on Kubernetes using Infrastructure as Code (IaC) and automated CI/CD.

The pipeline's flow is as follows:
1.  **MySQL Database** is initialized with a schema and test data for `Customers`, `Accounts`, and `Charges`.
2.  A Java-based **`producer`** service queries this data from MySQL and pushes it into Kafka topics.
3.  A Java-based **`consumer`** service subscribes to these topics, processes the data, and inserts it back into the MySQL database.
4.  The entire stack is designed for Kubernetes, managed by **Helm**, and provisioned by **Terraform**.

## 🏛️ Architecture

* **Data Flow:** `MySQL` (Source Tables) → `Producer Service` → `Kafka Cluster` → `Consumer Service` → `MySQL` (Destination Tables)
* **IaC (Terraform):** Manages the creation of the EKS cluster, VPC, node groups, and IAM roles.
* **Orchestration (Kubernetes):**
    * **Kafka:** Deployed and managed by the **Strimzi Operator**.
    * **MySQL:** Deployed as a stateful application using a `Deployment`, `Service`, `PVC`, and `ConfigMap` for the initialization script.
    * **Applications:** `producer` and `consumer` services are deployed as `Deployments` with liveness/readiness probes and configured to connect to Kafka and MySQL.
* **CI/CD (GitHub Actions):** An automated workflow builds the Java applications (skipping tests), containerizes them, and pushes the images to AWS ECR.

## 🛠️ Technologies Used

* **IaC:** Terraform
* **Cloud:** AWS (EKS, ECR, IAM OIDC)
* **Orchestration:** Kubernetes, Helm
* **Containers:** Docker, `docker-compose` (for local dev)
* **Data:** MySQL 8.0, Kafka (managed by Strimzi)
* **Application:** Java 17, Spring Boot, Maven
* **CI/CD:** GitHub Actions

## 📁 Repository Structure

```

.
├── .github/workflows/      \# GitHub Actions CI/CD pipeline for building images
├── common-files/           \# Java source code (common, producer, consumer) and init.sql
│   ├── common/
│   ├── consumer/
│   ├── producer/
│   └── init.sql
├── kafka/                  \# Local development environment files
│   ├── docker-compose.yaml
│   └── setup-dev.sh
├── kubernetes/             \# Helm chart for the full data-shipper application
│   ├── Chart.yaml
│   ├── templates/          \# K8s manifests (producer, consumer, mysql, etc.)
│   └── values.yaml
├── terraform/              \# Terraform modules for AWS infrastructure (EKS, VPC)
└── README.md               \# This file

````

## 🚀 Getting Started

### Prerequisites

* Git
* Maven
* Docker & `docker-compose`
* `kubectl`
* `helm`
* `terraform`
* AWS CLI configured with appropriate permissions

---

### 1. Local Development (Docker Compose)

This method spins up the entire stack on your local machine for testing.

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/liormilliger/kafka-data-shipper.git](https://github.com/liormilliger/kafka-data-shipper.git)
    cd kafka-data-shipper/kafka
    ```

2.  **Run the setup script:**
    This script will install dependencies, build the Java JARs (skipping tests), generate a KRaft Cluster ID for Kafka, update the `docker-compose.yaml` file, and start all services.
    ```bash
    chmod +x setup-dev.sh
    ./setup-dev.sh
    ```

3.  **Monitor the stack:**
    You can view the logs from all services (MySQL, Kafka, producer, consumer) to see the data flow.
    ```bash
    sudo docker-compose logs -f
    ```

4.  **Trigger the producer (Optional):**
    To manually send 100 records from MySQL to Kafka:
    ```bash
    curl -X POST http://localhost:9000/producer/?count=100
    ```

---

### 2. Full Kubernetes Deployment (E2E)

This is the production-grade deployment process.

#### Step 1: Build and Push Docker Images (CI)

The GitHub Actions workflow automates building the `producer` and `consumer` images and pushing them to your private AWS ECR.

1.  **Configure Secrets:** In your GitHub repository, go to `Settings > Secrets and variables > Actions` and add:
    * `AWS_ACCOUNT_ID`: Your 12-digit AWS account ID.
    * `AWS_ROLE_ARN`: The ARN of the IAM role for GitHub Actions to assume (must have ECR push permissions).

2.  **Run the Workflow:**
    * Go to the **Actions** tab in your GitHub repo.
    * Select the **"Manual Build and Push to ECR"** workflow.
    * Click **"Run workflow"**.

This will build the images and tag them as `<account-id>.dkr.ecr.us-east-1.amazonaws.com/kafka-data-shipper:producer-latest` and `...:consumer-latest`.

#### Step 2: Provision Infrastructure (Terraform)

Provision the EKS cluster, VPC, and node groups using the Terraform modules.

1.  Navigate to the Terraform directory:
    ```bash
    cd ../terraform/
    ```
2.  Initialize and apply Terraform:
    ```bash
    terraform init
    terraform plan
    terraform apply -auto-approve
    ```
3.  Configure `kubectl` to connect to your new EKS cluster:
    ```bash
    aws eks update-kubeconfig --region <your-region> --name <your-cluster-name>
    ```
4.  **Important:** Ensure a StorageClass is available for persistence. The `mysql-pvc.yaml` requires a `StorageClass` (e.g., `ebs-sc`). The `storage-class.yaml` file is provided in the Helm chart, but you may need to apply it or use an existing one (like `gp2`).

#### Step 3: Deploy the Full Application Stack (Helm)

This single Helm chart will deploy the Strimzi operator (as a dependency or prerequisite), MySQL, and your `producer` and `consumer` applications.

1.  **Install Strimzi Operator:** This is a one-time setup to manage your Kafka cluster.
    ```bash
    helm repo add strimzi [https://strimzi.io/charts/](https://strimzi.io/charts/)
    helm install strimzi-operator strimzi/strimzi-kafka-operator --namespace kafka --create-namespace
    ```

2.  **Navigate to the Helm chart:**
    ```bash
    cd ../kubernetes/
    ```

3.  **Update `values.yaml`:**
    You **must** update `kubernetes/values.yaml` (or create a `my-values.yaml`) to point to the ECR images pushed in Step 1.

    ```yaml
    # Example values to override in kubernetes/values.yaml
    awsAccountID: "YOUR_AWS_ACCOUNT_ID"

    producer:
      image:
        repository: "kafka-data-shipper"
        tag: "producer-latest"
      
    consumer:
      image:
        repository: "kafka-data-shipper"
        tag: "consumer-latest"
    
    # Ensure this matches your Kafka cluster's bootstrap service
    kafkaBootstrapServers: "my-kafka-cluster-kafka-bootstrap:9092" 
    ```

4.  **Install the Helm Chart:**
    This command deploys MySQL (which loads `init.sql` from the `ConfigMap`), the Kafka cluster, the producer, and the consumer.
    ```bash
    # (Install dependencies if Kafka/MySQL are defined as sub-charts)
    # helm dependency build . 

    helm install data-shipper . --namespace kafka
    ```

### 3. Verify the Deployment

After a few minutes, all pods should be running.

```bash
# Check all pods in the 'kafka' namespace
kubectl get pods -n kafka

# You should see pods for:
# - strimzi-operator
# - my-kafka-cluster-zookeeper / my-kafka-cluster-kafka
# - mysql-deployment-...
# - producer-deployment-...
# - consumer-deployment-...

# Check the logs of the producer and consumer to see the data flow
kubectl logs -f -n kafka -l app=producer
kubectl logs -f -n kafka -l app=consumer
````

```
```