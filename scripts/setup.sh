#!/usr/bin/env bash

############################################
#
# Initial setup for ElasticSearch index
#
############################################

SCRIPTS_DIR=./scripts/meta-data-index
DATA_DIR=./data

pig -x local \
  -p "SOURCE_DATA=${DATA_DIR}/users_meta.csv" \
  -p 'ELASTIC_SEARCH_INDEX=users/user' \
  -f ${SCRIPTS_DIR}/index_users_meta.pig

pig -x local \
  -p "SOURCE_DATA=${DATA_DIR}/videos_meta.tsv" \
  -p 'ELASTIC_SEARCH_INDEX=videos/video' \
  -f ${SCRIPTS_DIR}/index_video_meta.pig

pig -x local \
  -p "SOURCE_DATA=${DATA_DIR}/videos_meta.tsv" \
  -p 'ELASTIC_SEARCH_INDEX=shows/show' \
  -f ${SCRIPTS_DIR}/index_show_meta.pig
