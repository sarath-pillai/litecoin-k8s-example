# litecoin-k8s-example

This repository contains a dockerfile for litecoin, with a basic Jenkins pipeline that can be used to deploy this to a k8s cluster using a statefulset. This also holds a terraform directory that depicts how a set of IAM resources can be created with proper policy and roles. Apart from this, there is shell based and python based string manipulation example as well.

## Litecoin Docker

To stick with the docker best practices, we have used `alpine` base image for our litecoin image. Unlike Ubuntu, or any other debian image, using alpine we were able to get a final docker litecoin image of the size ~ 23.8MB. 

The image is tested for both build & runtime. 

Alpine by default does not ship with glibc package. Installing glibc was not that straightforward in alpine (see the dockerfile comments., with original source from where the glibc installation part was taken).

You can either use the Jenkinsfile or build the image manually using the below command. 

```bash
docker build -t sarathp88/litecoin:0.18.1 .
```

You can alternatively pull the already built existing image using the below command. 

```
docker pull sarathp88/litecoin:0.18.1
```

We could have used docker multi stage build process for litecoin. However, that was not much required in this case, as we are not exactly building litecoin from source code. We are just downloading binaries and extracting it. In the case of building from source, multi stage build process will be more appropriate.

## Jenkinsfile
The Jenkinsfile in this repository uses the docker pipeline plugin in jenkins to do the docker build. There are several prerequisites for this to work in Jenkins. 

- https://plugins.jenkins.io/docker-workflow/ plugin needs to be installed in jenkins.
- Docker should be installed and usable by Jenkins (basically Jenkins should be able to talk to docker socket file without any permission issue. `usermod -a -G docker jenkins`)
- kubectl should be installed on the jenkins node.
- there should be a credential in jenkins named `dockerhub`, for dockerhub authentication and the registry specified in the Jenkinsfile can be modified to any other registry for testing (dockerhub is the registry here). The dockerhub credential can be added to Jenkins with the jenkins credential kind of `username with password`.
- this Jenkinsfile also expects the jenkinsnode to have kubernetes authentication configured. 

One important thing to note here is that each time jenkins builds the image, it will add the git commit hash as the image tag, so that we get unique images each time.

There is a dirty trick used in the Jenkinsfile using `sed` to edit the image tag before deployment using `kubectl`. Although this works, its not ideal. Much better will be to use something like kubernetes `kustomize` or even a helm chart with values passed during deployment that overrides default values.yaml.  But this is just for illustration purpose. 


## Text manipulation

We have an example text manipulation issue in this repository. I have copied an nginx access.log file from my drupal backend server(personal blog), and we can use the manipulation techniques with bash(sed & awk) and also the same with a simple python script. 

Basically find out number of requests from different IPs. There is one important thing to remember here, the log fields matter the most. Both the bash based solution & python based solution assumes the field of IP address to be at a particular location. Well this is expected because even web server configuration has options to specify the exact formatting of the log for predictability.

```bash
cd text-manipulation
sh sort-ips-by-number-of-requests.sh
```

Below shown is an output snippet for the above command.

```
  97 85.208.122.79
 145 95.216.185.165
 192 155.94.240.138
 212 155.94.240.238
 226 131.108.16.48
 229 141.98.133.188
 248 107.174.148.113
```

You can achieve the same using a python script in the same folder, as shown below. 

```
python3 sort-ips-by-number-of-requests.py access.log
```

Another manipulation we did with sed is to replace some sensitive stuff in a file. For example, we redacted all IP address in the file using sed to localhost. 

```
sh redact-ip-address-using-sed.sh
```

If you open the file `redact-ip-address-using-sed.sh` you will notice that we have not used the `-i` option in sed. Using -i will modify the actual file. 


## Terraform

We have a small terraform module, that creates the below resources in AWS. 
- an iam role
- a policy, with assume role
- a user with a group

We used the terraform module structure for this. 

basically get inside the `terraform` directory and do the below. 

```
terraform init
terraform apply
```

It should show `Plan: 6 to add, 0 to change, 0 to destroy.

### Note: 
The above assumes you have access to an aws account and have credentials configured locally
