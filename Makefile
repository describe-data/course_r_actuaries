PROJECT_USER=describedata
PROJECT_NAME=course_r_actuaries
PROJECT_TAG=202003

DOCKER_USER=student

IMAGE_TAG=${PROJECT_USER}/${PROJECT_NAME}:${PROJECT_TAG}

GCLOUD_PROJECT=$(shell gcloud config get-value project)
PROJECT=${GCLOUD_PROJECT}

# # kompreno
SERVICE_IAM_ACCOUNT=$(shell gcloud iam service-accounts list --filter=name:"${NAME}" --format='value(email)')

REPO_NAME=$(shell basename -s .git `git config --get remote.origin.url`)
SERVICE_URL="$(shell gcloud beta run services describe ${REPO_NAME} --platform=managed --region=europe-west1 --format="get(status.url)")"
TOKEN="$(shell gcloud auth print-identity-token)"
PROJECT=$(shell gcloud config get-value project)
SERVICE_ACCOUNT=$(shell gcloud projects list --filter="${PROJECT}" --format="value(PROJECT_NUMBER)")

docker-build-image: Dockerfile
	docker build -t ${IMAGE_TAG} -f Dockerfile .

docker-run:
	docker run --rm -d \
	  -p 8787:8787 \
	  -e USER=${DOCKER_USER} \
	  -e PASSWORD=password \
	  ${IMAGE_TAG}

echo-reponame:
	echo "${REPO_NAME}"
docker-stop:
	docker stop $(shell docker ps -q -a)

docker-clean:
	docker rm $(shell docker ps -q -a)

docker-pull:
	docker pull ${IMAGE_TAG}

docker-push:
	docker push ${IMAGE_TAG}


