FROM rocker/tidyverse:3.6.1


RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    git \
    htop \
    byobu \
  && apt-get clean \
  && mkdir -p $HOME/.R \
  && install2.r --error \
    cowplot \
    snakecase \
    fs \
    fitdistrplus

RUN Rscript -e 'install.packages("CASdatasets", repos = "http://cas.uqam.ca/pub/R/", type="source")'

COPY *.Rmd /home/rstudio/course_r_actuaries/
COPY *.R /home/rstudio/course_r_actuaries/
COPY course_r_actuaries.Rproj /home/rstudio/course_r_actuaries/
COPY data/* /home/rstudio/course_r_actuaries/data/




