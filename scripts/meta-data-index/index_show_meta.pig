/*
* Store shows meta-data into Elasticsearch
*
* Required params:
* SOURCE_DATA - TSV as source with meta-data
* ELASTIC_SEARCH_INDEX - where to store
*/

shows = LOAD '$SOURCE_DATA' 
    USING org.apache.pig.piggybank.storage.CSVExcelStorage('\t', 'NO_MULTILINE', 'UNIX', 'SKIP_INPUT_HEADER') 
    AS (video_id:chararray, programa_id:chararray, programa_titulo:chararray, 
        programa_descricao:chararray, categoria:chararray, titulo:chararray, descricao:chararray, tags:chararray);

shows = FOREACH shows GENERATE programa_id AS id, programa_titulo AS titulo, programa_descricao AS descricao;

STORE shows INTO '$ELASTIC_SEARCH_INDEX' USING org.elasticsearch.hadoop.pig.EsStorage('es.mapping.id=id');
