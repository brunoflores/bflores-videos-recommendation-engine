/*
* Store users meta-data into Elasticsearch
*
* Required params:
* SOURCE_DATA - CSV as source with meta-data
* ELASTIC_SEARCH_INDEX - where to store
*/

users = LOAD '$SOURCE_DATA' 
    USING org.apache.pig.piggybank.storage.CSVExcelStorage(';', 'NO_MULTILINE', 'UNIX', 'SKIP_INPUT_HEADER') 
    AS (usuario_id:chararray, videos:chararray, programas:chararray);

users = FOREACH users {
    videos = TOKENIZE(videos, ', ');
    shows = TOKENIZE(programas, ', ');
    GENERATE usuario_id, videos AS videos, shows AS shows;
};

STORE users INTO '$ELASTIC_SEARCH_INDEX' USING org.elasticsearch.hadoop.pig.EsStorage('es.mapping.id=usuario_id');
