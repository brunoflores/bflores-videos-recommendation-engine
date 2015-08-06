users_shows = LOAD '$SOURCE_CSV'
    USING PigStorage(',') 
    AS (usuario_id:chararray, programa_id:chararray, preference:int);

users = FOREACH users_shows GENERATE usuario_id;
unique_users = DISTINCT users;
new_users = RANK unique_users;

shows = FOREACH users_shows GENERATE programa_id;
unique_shows = DISTINCT shows;
new_shows = RANK unique_shows;

rmf $DICTIONARY
STORE new_shows INTO '$DICTIONARY' USING PigStorage(',');

new_users_shows = JOIN users_shows BY usuario_id, new_users BY usuario_id;
new_users_shows = JOIN new_users_shows BY programa_id, new_shows BY programa_id;
new_users_shows = FOREACH new_users_shows GENERATE rank_unique_users, rank_unique_shows, preference;

rmf $DESTINATION_CSV
STORE new_users_shows INTO '$DESTINATION_CSV' USING PigStorage(',');
