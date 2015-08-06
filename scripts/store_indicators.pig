/*
* Playbook:
* 1. Receives a CSV from Mahout
* 2. Pass through the Dictionary
* 3. Store into Elasticsearch
*/

videos_views = LOAD '$SIMILARITIES_CSV' 
    USING PigStorage(',') 
    AS (item_target_id:int, item_similar_id:int);

dictionary = LOAD '$DICTIONARY'
    USING PigStorage(',')
    AS (mapped_id:int, video_id:chararray);

A = JOIN videos_views BY item_target_id, dictionary BY mapped_id;
A = JOIN A BY item_similar_id, dictionary BY mapped_id;

B = FOREACH A GENERATE $3, $5;

C = FOREACH (GROUP B BY $0) { GENERATE $0 AS id, $1.$1 AS indicators; };

STORE C INTO '$ELASTIC_SEARCH_INDEX' 
    USING org.elasticsearch.hadoop.pig.EsStorage(
        'es.mapping.id=id', 
        'es.index.auto.create=false', 
        'es.write.operation=upsert');
