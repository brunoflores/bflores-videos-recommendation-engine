#!/usr/bin/env bash

#######################################
# Playbook:
# 
# 1.  First all ID's are mapped to integers;
# 2.  Similarities for videos are pre-processed with Mahout;
# 3.  Integers are mapped back to ID's;
# 4.  ElasticSearch indexes "video" similarities;
# 6.  ID's for user-show preferences are mapped to integers;
# 7.  Similarities for shows are pre-processed with Mahout;
# 8.  Integers are mapped back to ID's;
# 9.  ElasticSearch indexes "shows" similarities.
#
#######################################

SCRIPTS_DIR=./scripts
DATA_DIR=./data
TMP_DIR=${DATA_DIR}/tmp

echo -e "\033[1;32mLendo log usuarios-vídeos e preparando para o Mahout...\033[0m"
pig -x local \
  -p "SOURCE_CSV=${DATA_DIR}/video_views.csv" \
  -p "DICTIONARY=${TMP_DIR}/dictionary" \
  -p "DESTINATION_CSV=${TMP_DIR}/mahout_ready" \
  -f ${SCRIPTS_DIR}/prep_user_video.pig
echo -e "\033[1;32mPronto! Entregando CSV para o Mahout.\033[0m"

echo -e "\033[1;32mCompilando aplicação Mahout (na primeira vez será feito download das dependências por Maven)...\033[0m"
(cd ml-app/Recommender; mvn compile)

echo -e "\033[1;32mComputando recomendações de vídeos...\033[0m"
(cd ml-app/Recommender; mvn exec:java -Dexec.mainClass="com.bruno.Recommender.Videos")
echo -e "\033[1;32mCSV com recomendações produzido e pronto para ser indexado.\033[0m"

echo -e "\033[1;32mIndexando indicadores de vídeos no ElasticSearch...\033[0m"
pig -x local \
  -p "SIMILARITIES_CSV=${TMP_DIR}/similarities.csv" \
  -p "DICTIONARY=${TMP_DIR}/dictionary/part-m-00000" \
  -p "ELASTIC_SEARCH_INDEX=videos/video" \
  -f ${SCRIPTS_DIR}/store_indicators.pig
echo -e "\033[1;32mIndicadores de vídeos indexados!\033[0m"

echo -e "\033[1;32mLendo arquivo de preferências usuário-programa e preparando para o Mahout...\033[0m"
pig \
  -x local \
  -p "SOURCE_CSV=${DATA_DIR}/users_shows.csv" \
  -p "DICTIONARY=${TMP_DIR}/dictionary" \
  -p "DESTINATION_CSV=${TMP_DIR}/mahout_ready" \
  -f ${SCRIPTS_DIR}/prep_user_show.pig
echo -e "\033[1;32mPronto! Entregando CSV para o Mahout.\033[0m"

echo -e "\033[1;32mComputando recomendações de programas...\033[0m"
(cd ml-app/Recommender; mvn exec:java -Dexec.mainClass="com.bruno.Recommender.Shows")
echo -e "\033[1;32mCSV com recomendações produzido e pronto para ser indexado.\033[0m"

echo -e "\033[1;32mIndexando indicadores de programas no ElasticSearch...\033[0m"
pig -x local \
  -p "SIMILARITIES_CSV=${TMP_DIR}/similarities.csv" \
  -p "DICTIONARY=${TMP_DIR}/dictionary/part-m-00000" \
  -p "ELASTIC_SEARCH_INDEX=shows/show" \
  -f ${SCRIPTS_DIR}/store_indicators.pig
echo -e "\033[1;32mIndicadores de programas indexados!\033[0m"
