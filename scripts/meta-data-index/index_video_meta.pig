/*
* Store videos meta-data into Elasticsearch
*
* Required params:
* SOURCE_DATA - TSV as source with meta-data
* ELASTIC_SEARCH_INDEX - where to store
*/

videos = LOAD '$SOURCE_DATA' 
    USING org.apache.pig.piggybank.storage.CSVExcelStorage('\t', 'NO_MULTILINE', 'UNIX', 'SKIP_INPUT_HEADER') 
    AS (video_id:chararray, programa_id:chararray, programa_titulo:chararray, 
        programa_descricao:chararray, categoria:chararray, titulo:chararray, descricao:chararray, tags:chararray);

videos = FOREACH videos {
    tags = TOKENIZE(tags, ';');
    GENERATE video_id, programa_id, programa_titulo, programa_descricao, categoria, titulo, descricao, tags AS tags;
};

STORE videos INTO '$ELASTIC_SEARCH_INDEX' USING org.elasticsearch.hadoop.pig.EsStorage('es.mapping.id=video_id');
