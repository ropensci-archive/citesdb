FROM rocker/shiny-verse:3.5.1
MAINTAINER "Noam Ross" ross@ecohealthalliance.org

RUN install2.r --error --skipinstalled \
  shinydashboard \
  optimx \
  plotly \
  shinyWidgets \
  future \
  promises

RUN installGithub.r ecohealthalliance/shiny

COPY . /srv/shiny-server/
