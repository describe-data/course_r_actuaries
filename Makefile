### repo variables
PROJECT_USER=describe-data
PROJECT_NAME=r-actuaries
PROJECT_TAG=latest

IMAGE_TAG=${PROJECT_USER}/${PROJECT_NAME}:${PROJECT_TAG}

DOCKER_USER=rstudio
DOCKER_PASS=CHANGEME
DOCKER_UID=$(shell id -u)
DOCKER_GID=$(shell id -g)
DOCKER_BUILD_ARGS=

RSTUDIO_PORT=8787

PROJECT_FOLDER=r_actuaries


### Set GITHUB_USER with 'gh config set gh_user <<user>>'
GITHUB_USER=$(shell gh config get gh_user)

CONTAINER_NAME=r_course

### Project build targets
.SUFFIXES: .qmd .html .dot .png

QMD_FILES  := $(wildcard *.qmd)
HTML_FILES := $(patsubst %.qmd,%.html,$(QMD_FILES))

all-html: $(HTML_FILES)

.qmd.html:
	echo "TIMESTAMP:" `date` "- Rendering script $<"  >> output.log 2>&1
	quarto render $< --to html >> output.log 2>&1
	echo "TIMESTAMP:" `date` "- Finished $*.html"         >> output.log 2>&1


.dot.png:
	dot -Tpng -o$*.png $<

full_deps.dot:
	makefile2graph all-html > full_deps.dot

depgraph: full_deps.png



gh-create-issue:
	gh issue create \
	  --assignee ${GITHUB_USER} \
	  --project ${GITHUB_PROJECT} \
	  --label ${GITHUB_LABEL} \
	  --milestone ${GITHUB_MILESTONE}



echo-reponame:
	echo "${REPO_NAME}"

clean-html:
	rm -rfv *.html

clean-cache:
	rm -rfv *_cache
	rm -rfv *_files

mrproper:
	rm -rfv *.html
	rm -rfv *.dot
	rm -rfv *.png
	rm -rfv *_cache
	rm -rfv *_files
	rm -rfv data/*.rds
	rm -rfv geospatial_data/*.zip
	rm -rfv geospatial_data/FRA_adm*




docker-build-image: Dockerfile
	docker build -t ${IMAGE_TAG} -f Dockerfile .

docker-run:
	docker run --rm -d \
	  -p ${RSTUDIO_PORT}:8787 \
	  -v "${PWD}":"/home/${DOCKER_USER}/${PROJECT_NAME}":rw \
	  -e USER=${DOCKER_USER} \
	  -e PASSWORD=${DOCKER_PASS} \
	  -e USERID=${DOCKER_UID} \
	  -e GROUPID=${DOCKER_GID} \
	  --name ${CONTAINER_NAME} \
	  ${IMAGE_TAG}

docker-bash:
	docker exec -it -u ${DOCKER_USER} ${CONTAINER_NAME} bash



docker-stop:
	docker stop ${CONTAINER_NAME}

docker-clean:
	docker rm $(shell docker ps -q -a)

docker-login:
	cat $(HOME)/.dockerpass | docker login -u kaybenleroll --password-stdin

docker-pull:
	docker pull ${IMAGE_TAG}

docker-push:
	docker push ${IMAGE_TAG}
