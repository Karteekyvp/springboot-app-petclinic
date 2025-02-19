# 🚀 **Spring Boot Application & Infrastructure Deployment on AWS EKS using Jenkins Pipelines**

---

## 📖 **Overview**
This guide outlines the complete end-to-end deployment of a Spring Boot application on AWS EKS using two separate Jenkins pipelines:

1. **Infrastructure Pipeline:** Provisions AWS resources using Terraform.
2. **Application Pipeline:** Builds, scans, pushes the Docker image to AWS ECR, and deploys the application to EKS.

Both pipelines are automated, ensuring minimal manual intervention and seamless CI/CD.

---

## 📝 **Prerequisites**
- **AWS CLI**: Configured with appropriate IAM credentials.
- **Docker**: Installed and running.
- **Kubernetes CLI (kubectl)**: Installed and configured.
- **Terraform**: Installed for infrastructure management.
- **Jenkins**: Set up with necessary plugins for AWS, Docker, and Kubernetes.
- **AWS Resources**: ECR repository, VPC, EKS Cluster, Node Groups, and IAM roles.

---

## 🏗️ **1️⃣ Infrastructure Deployment Pipeline (Terraform)**
This pipeline handles the creation of AWS infrastructure components required for the application.

### 🚦 **Pipeline Stages:**
1. **Checkout Code**: Pulls Terraform scripts from GitHub.
2. **Terraform Init**: Initializes Terraform backend and modules.
3. **Terraform Plan**: Plans the infrastructure changes.
4. **Terraform Apply**: Applies the planned infrastructure.
5. **Post Deployment**: Verifies the EKS cluster and VPC setup.

### 🛠️ **Executed Commands:**
```bash
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

### ✅ **Verification:**
```bash
aws eks describe-cluster --name springboot-eks-cluster --query "cluster.status" --output text
aws eks update-kubeconfig --region us-east-1 --name springboot-eks-cluster
kubectl get nodes
```

✅ EKS Cluster status should be **ACTIVE** with all nodes in **Ready** state.

---

## 📦 **2️⃣ Application Deployment Pipeline (Docker + Kubernetes)**
This pipeline focuses on building the application, performing security scans, and deploying it to the EKS cluster.

### 🚦 **Pipeline Stages:**
1. **Checkout Code**: Retrieves application source code from GitHub.
2. **Security Scan (Trivy)**: Scans code for vulnerabilities.
3. **Build & Push Docker Image**: Builds Docker image and pushes to AWS ECR.
4. **Deploy to EKS**: Deploys the application using Kubernetes manifests.
5. **Post Deployment Verification**: Ensures application is running and accessible.

### 🔑 **Docker Image Build & Push Steps:**
```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# Build and push Docker image
docker build -t <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/springboot-app:latest .
docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/springboot-app:latest
```

### ☸️ **Deploy Application to EKS:**
```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### 🚀 **Verify Application Deployment:**
```bash
kubectl get deployments
kubectl get pods
kubectl get svc springboot-app
```
✅ Pods should be in **Running** state and a **LoadBalancer** service should provide an **EXTERNAL-IP** for access.

---

## 🔄 **Auto-Scaling & High Availability Test**
### 🧪 **Steps to Test Auto-Scaling:**
1. **Manually terminate an EC2 instance:**
```bash
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].[InstanceId,State.Name]" --output table
aws ec2 terminate-instances --instance-ids <INSTANCE_ID>
```
2. **Verify EKS Node Group Auto-Recovery:**
```bash
kubectl get nodes
```
✅ EKS should automatically replace the terminated node.

---

## 🌐 **Accessing the Spring Boot Application**
1. **Get the Load Balancer URL:**
```bash
kubectl get svc springboot-app
```
2. **Access Application:**
Use the **EXTERNAL-IP** to access the application:
```
http://<EXTERNAL-IP>
```
✅ Application should be up and accessible in the browser.

---

## 📊 **Architecture Overview**
```
+----------------+        +---------------------+        +----------------+        +-------------------+
|  Jenkins CI/CD | -----> | AWS Infrastructure  | -----> | Docker & ECR    | -----> | AWS EKS Cluster    |
+----------------+        +---------------------+        +----------------+        +-------------------+
      |                                |                             |                          |
      |                                |                             |                          |
      |--- Infra Pipeline ------------>|                             |                          |
      |                                |--- EKS & VPC Setup -------->|                          |
      |                                |                             |--- Image Pull ---------->|
      |--- App Pipeline -------------->|                             |                          |
```

---

## 🏆 **Final Notes:**
✅ Fully automated infrastructure and application deployment with Jenkins pipelines.  
✅ Infrastructure managed with Terraform ensures reproducibility.  
✅ Continuous integration with Docker and ECR for seamless deployments.  
✅ High availability and auto-healing enabled via AWS EKS Node Groups.  

---

## 🎉 **Success! Your Spring Boot application is live on AWS EKS with automated CI/CD!** 🚀



# 🚑 **Troubleshooting Guide: AWS EKS Deployment Using Jenkins Pipelines**

This guide details the issues encountered during the end-to-end deployment of infrastructure and a Spring Boot application on AWS EKS using two Jenkins pipelines—one for infrastructure and one for application deployment. Each issue is documented chronologically with its root cause, resolution steps, commands used, and how the problem was resolved.

---

## 🛠️ **1️⃣ Issue: Terraform State File Not Persisting in S3**
### 📝 **Description:**
The Terraform state file was not being stored in the configured S3 bucket, causing issues with state management.

### 🔎 **Root Cause:**
The backend configuration was not correctly initialized with S3 and DynamoDB, and the state file was being stored locally instead.

### 🚫 **Error Message:**
```
No state file was found!
```

### 🩹 **Solution Steps:**
1. Verified S3 bucket and DynamoDB table creation.
2. Re-initialized Terraform with the `-reconfigure` flag to set the backend.
3. Manually uploaded the `terraform.tfstate` file to S3.

### ✅ **Commands Used:**
```bash
terraform init -reconfigure
aws s3 cp terraform.tfstate s3://<BUCKET_NAME>/terraform/statefile.tfstate
terraform state list
```

---

## 🛠️ **2️⃣ Issue: Jenkins Pipeline - Trivy Installation Permission Denied**
### 📝 **Description:**
The security scan stage in the Jenkins pipeline failed due to Trivy installation permission issues.

### 🔎 **Root Cause:**
Jenkins did not have write permissions to `/usr/local/bin/`, the default installation path.

### 🚫 **Error Message:**
```
install: /usr/local/bin/trivy: Permission denied
```

### 🩹 **Solution Steps:**
- Changed the installation path to `/tmp`, which Jenkins had permissions to write to.

### ✅ **Updated Jenkinsfile Snippet:**
```bash
export TRIVY_PATH="/tmp/trivy"
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /tmp
```

---

## 🛠️ **3️⃣ Issue: Docker Image Build Failure - JAR File Not Found**
### 📝 **Description:**
The Docker build failed due to the absence of the Spring Boot JAR file.

### 🔎 **Root Cause:**
The Maven build stage was skipped, resulting in the `target/` directory not having the required JAR.

### 🚫 **Error Message:**
```
COPY failed: stat target/spring-petclinic-*.jar: no such file or directory
```

### 🩹 **Solution Steps:**
1. Added a Maven build stage in the Jenkins pipeline.
2. Verified the JAR file was generated in the `target/` directory.

### ✅ **Commands Used:**
```bash
mvn clean package -DskipTests
ls target/
```

---

## 🛠️ **4️⃣ Issue: Docker Image Push to ECR Fails - Access Denied**
### 📝 **Description:**
Docker push to AWS ECR was failing with an authentication error.

### 🔎 **Root Cause:**
The IAM user used by Jenkins lacked the necessary ECR permissions.

### 🚫 **Error Message:**
```
unauthorized: authentication required
```

### 🩹 **Solution Steps:**
1. Attached the `AmazonEC2ContainerRegistryFullAccess` policy to the IAM user.
2. Re-authenticated Docker with ECR.

### ✅ **Commands Used:**
```bash
aws iam attach-user-policy --user-name <IAM_USER> --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ECR_REPO>
```

---

## 🛠️ **5️⃣ Issue: ImagePullBackOff in Kubernetes Pods**
### 📝 **Description:**
Pods failed to pull the Docker image from ECR, preventing deployment.

### 🔎 **Root Cause:**
Kubernetes could not authenticate with ECR due to a missing `imagePullSecret`.

### 🚫 **Error Message:**
```
Failed to pull image: no match for platform in manifest: not found
ImagePullBackOff
```

### 🩹 **Solution Steps:**
1. Created an ECR pull secret.
2. Linked the secret to the default service account.
3. Restarted the deployment to pull the image successfully.

### ✅ **Commands Used:**
```bash
kubectl create secret docker-registry ecr-secret \
  --docker-server=<AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-1)

kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "ecr-secret"}]}'
kubectl rollout restart deployment springboot-app
```

---

## 🛠️ **6️⃣ Issue: EKS Connection Issues - Cluster Endpoint Not Reachable**
### 📝 **Description:**
Commands interacting with the Kubernetes cluster failed due to endpoint issues.

### 🔎 **Root Cause:**
The kubeconfig context was outdated, and the client could not resolve the EKS cluster endpoint.

### 🚫 **Error Message:**
```
dial tcp: lookup <EKS_ENDPOINT>: no such host
```

### 🩹 **Solution Steps:**
1. Updated the kubeconfig to refresh cluster credentials.
2. Confirmed cluster status was `ACTIVE`.

### ✅ **Commands Used:**
```bash
aws eks update-kubeconfig --region us-east-1 --name springboot-eks-cluster
kubectl get nodes
aws eks describe-cluster --name springboot-eks-cluster --query "cluster.status" --output text
```

---

## 🛠️ **7️⃣ Issue: Auto-Scaling Validation Post EC2 Termination**
### 📝 **Description:**
An EC2 instance was manually terminated to verify EKS node group auto-scaling functionality.

### 🔎 **Root Cause:**
Testing EKS auto-scaling behavior to ensure resilience in case of node failures.

### 🩹 **Solution Steps:**
1. Terminated a node from the EC2 console.
2. Verified that the node group auto-provisioned a new instance.

### ✅ **Commands Used:**
```bash
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].[InstanceId,State.Name]" --output table
aws ec2 terminate-instances --instance-ids <INSTANCE_ID>
kubectl get nodes
```
✅ New node successfully joined the cluster.

---

## 🏆 **Final Thoughts:**
✅ All issues were resolved systematically with root causes analyzed and documented.
✅ Jenkins pipelines are now fully automated for both infrastructure and application deployments.
✅ EKS cluster is resilient with auto-scaling and seamless deployments.

---

🎉 **Deployment and troubleshooting successfully completed!** 🚀





# Spring PetClinic Sample Application [![Build Status](https://github.com/spring-projects/spring-petclinic/actions/workflows/maven-build.yml/badge.svg)](https://github.com/spring-projects/spring-petclinic/actions/workflows/maven-build.yml)[![Build Status](https://github.com/spring-projects/spring-petclinic/actions/workflows/gradle-build.yml/badge.svg)](https://github.com/spring-projects/spring-petclinic/actions/workflows/gradle-build.yml)

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/spring-projects/spring-petclinic) [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=7517918)

## Understanding the Spring Petclinic application with a few diagrams

[See the presentation here](https://speakerdeck.com/michaelisvy/spring-petclinic-sample-application)

## Run Petclinic locally

Spring Petclinic is a [Spring Boot](https://spring.io/guides/gs/spring-boot) application built using [Maven](https://spring.io/guides/gs/maven/) or [Gradle](https://spring.io/guides/gs/gradle/). You can build a jar file and run it from the command line (it should work just as well with Java 17 or newer):

```bash
git clone https://github.com/spring-projects/spring-petclinic.git
cd spring-petclinic
./mvnw package
java -jar target/*.jar
```

You can then access the Petclinic at <http://localhost:8080/>.

<img width="1042" alt="petclinic-screenshot" src="https://cloud.githubusercontent.com/assets/838318/19727082/2aee6d6c-9b8e-11e6-81fe-e889a5ddfded.png">

Or you can run it from Maven directly using the Spring Boot Maven plugin. If you do this, it will pick up changes that you make in the project immediately (changes to Java source files require a compile as well - most people use an IDE for this):

```bash
./mvnw spring-boot:run
```

> NOTE: If you prefer to use Gradle, you can build the app using `./gradlew build` and look for the jar file in `build/libs`.

## Building a Container

There is no `Dockerfile` in this project. You can build a container image (if you have a docker daemon) using the Spring Boot build plugin:

```bash
./mvnw spring-boot:build-image
```

## In case you find a bug/suggested improvement for Spring Petclinic

Our issue tracker is available [here](https://github.com/spring-projects/spring-petclinic/issues).

## Database configuration

In its default configuration, Petclinic uses an in-memory database (H2) which
gets populated at startup with data. The h2 console is exposed at `http://localhost:8080/h2-console`,
and it is possible to inspect the content of the database using the `jdbc:h2:mem:<uuid>` URL. The UUID is printed at startup to the console.

A similar setup is provided for MySQL and PostgreSQL if a persistent database configuration is needed. Note that whenever the database type changes, the app needs to run with a different profile: `spring.profiles.active=mysql` for MySQL or `spring.profiles.active=postgres` for PostgreSQL. See the [Spring Boot documentation](https://docs.spring.io/spring-boot/how-to/properties-and-configuration.html#howto.properties-and-configuration.set-active-spring-profiles) for more detail on how to set the active profile.

You can start MySQL or PostgreSQL locally with whatever installer works for your OS or use docker:

```bash
docker run -e MYSQL_USER=petclinic -e MYSQL_PASSWORD=petclinic -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=petclinic -p 3306:3306 mysql:9.1
```

or

```bash
docker run -e POSTGRES_USER=petclinic -e POSTGRES_PASSWORD=petclinic -e POSTGRES_DB=petclinic -p 5432:5432 postgres:17.0
```

Further documentation is provided for [MySQL](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/resources/db/mysql/petclinic_db_setup_mysql.txt)
and [PostgreSQL](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/resources/db/postgres/petclinic_db_setup_postgres.txt).

Instead of vanilla `docker` you can also use the provided `docker-compose.yml` file to start the database containers. Each one has a service named after the Spring profile:

```bash
docker compose up mysql
```

or

```bash
docker compose up postgres
```

## Test Applications

At development time we recommend you use the test applications set up as `main()` methods in `PetClinicIntegrationTests` (using the default H2 database and also adding Spring Boot Devtools), `MySqlTestApplication` and `PostgresIntegrationTests`. These are set up so that you can run the apps in your IDE to get fast feedback and also run the same classes as integration tests against the respective database. The MySql integration tests use Testcontainers to start the database in a Docker container, and the Postgres tests use Docker Compose to do the same thing.

## Compiling the CSS

There is a `petclinic.css` in `src/main/resources/static/resources/css`. It was generated from the `petclinic.scss` source, combined with the [Bootstrap](https://getbootstrap.com/) library. If you make changes to the `scss`, or upgrade Bootstrap, you will need to re-compile the CSS resources using the Maven profile "css", i.e. `./mvnw package -P css`. There is no build profile for Gradle to compile the CSS.

## Working with Petclinic in your IDE

### Prerequisites

The following items should be installed in your system:

- Java 17 or newer (full JDK, not a JRE)
- [Git command line tool](https://help.github.com/articles/set-up-git)
- Your preferred IDE
  - Eclipse with the m2e plugin. Note: when m2e is available, there is an m2 icon in `Help -> About` dialog. If m2e is
  not there, follow the install process [here](https://www.eclipse.org/m2e/)
  - [Spring Tools Suite](https://spring.io/tools) (STS)
  - [IntelliJ IDEA](https://www.jetbrains.com/idea/)
  - [VS Code](https://code.visualstudio.com)

### Steps

1. On the command line run:

    ```bash
    git clone https://github.com/spring-projects/spring-petclinic.git
    ```

1. Inside Eclipse or STS:

    Open the project via `File -> Import -> Maven -> Existing Maven project`, then select the root directory of the cloned repo.

    Then either build on the command line `./mvnw generate-resources` or use the Eclipse launcher (right-click on project and `Run As -> Maven install`) to generate the CSS. Run the application's main method by right-clicking on it and choosing `Run As -> Java Application`.

1. Inside IntelliJ IDEA:

    In the main menu, choose `File -> Open` and select the Petclinic [pom.xml](pom.xml). Click on the `Open` button.

    - CSS files are generated from the Maven build. You can build them on the command line `./mvnw generate-resources` or right-click on the `spring-petclinic` project then `Maven -> Generates sources and Update Folders`.

    - A run configuration named `PetClinicApplication` should have been created for you if you're using a recent Ultimate version. Otherwise, run the application by right-clicking on the `PetClinicApplication` main class and choosing `Run 'PetClinicApplication'`.

1. Navigate to the Petclinic

    Visit [http://localhost:8080](http://localhost:8080) in your browser.

## Looking for something in particular?

|Spring Boot Configuration | Class or Java property files  |
|--------------------------|---|
|The Main Class | [PetClinicApplication](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/java/org/springframework/samples/petclinic/PetClinicApplication.java) |
|Properties Files | [application.properties](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/resources) |
|Caching | [CacheConfiguration](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/java/org/springframework/samples/petclinic/system/CacheConfiguration.java) |

## Interesting Spring Petclinic branches and forks

The Spring Petclinic "main" branch in the [spring-projects](https://github.com/spring-projects/spring-petclinic)
GitHub org is the "canonical" implementation based on Spring Boot and Thymeleaf. There are
[quite a few forks](https://spring-petclinic.github.io/docs/forks.html) in the GitHub org
[spring-petclinic](https://github.com/spring-petclinic). If you are interested in using a different technology stack to implement the Pet Clinic, please join the community there.

## Interaction with other open-source projects

One of the best parts about working on the Spring Petclinic application is that we have the opportunity to work in direct contact with many Open Source projects. We found bugs/suggested improvements on various topics such as Spring, Spring Data, Bean Validation and even Eclipse! In many cases, they've been fixed/implemented in just a few days.
Here is a list of them:

| Name | Issue |
|------|-------|
| Spring JDBC: simplify usage of NamedParameterJdbcTemplate | [SPR-10256](https://github.com/spring-projects/spring-framework/issues/14889) and [SPR-10257](https://github.com/spring-projects/spring-framework/issues/14890) |
| Bean Validation / Hibernate Validator: simplify Maven dependencies and backward compatibility |[HV-790](https://hibernate.atlassian.net/browse/HV-790) and [HV-792](https://hibernate.atlassian.net/browse/HV-792) |
| Spring Data: provide more flexibility when working with JPQL queries | [DATAJPA-292](https://github.com/spring-projects/spring-data-jpa/issues/704) |

## Contributing

The [issue tracker](https://github.com/spring-projects/spring-petclinic/issues) is the preferred channel for bug reports, feature requests and submitting pull requests.

For pull requests, editor preferences are available in the [editor config](.editorconfig) for easy use in common text editors. Read more and download plugins at <https://editorconfig.org>. If you have not previously done so, please fill out and submit the [Contributor License Agreement](https://cla.pivotal.io/sign/spring).

## License

The Spring PetClinic sample application is released under version 2.0 of the [Apache License](https://www.apache.org/licenses/LICENSE-2.0).
