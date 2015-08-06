/*
INPUT

usuario_id,video_id,porcentagem_vista,ultima_visualizacao
f3c18ff17981963f,efac34dbae7d546f,1.866467244564445,1417796642643
ad7f9222659e9dbd,efac34dbae7d546f,0.7997271564587182,1417696059807
*/

/*
DICTIONARY

f3c18ff17981963f,1
efac34dbae7d546f,2
ad7f9222659e9dbd,3
*/

/*
OUTPUT

1,2
3,2
*/

videos_views = LOAD '$SOURCE_CSV'
    USING org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE', 'UNIX', 'SKIP_INPUT_HEADER') 
    AS (usuario_id:chararray, video_id:chararray, porcentagem_vista:double);

videos_views = FILTER videos_views BY porcentagem_vista >= 0.5;
videos_views = FOREACH videos_views GENERATE usuario_id, video_id;

users = FOREACH videos_views GENERATE usuario_id;
unique_users = DISTINCT users;
new_users = RANK unique_users;
/*
(1,usuario_id)
(2,05055a341480a04f)
(3,3aca5ff7d0ccb963)
(4,3d04a3328a3bff1c)
(5,737c96b151e93a3b)
*/

videos = FOREACH videos_views GENERATE video_id;
unique_videos = DISTINCT videos;
new_videos = RANK unique_videos;

rmf $DICTIONARY
STORE new_videos INTO '$DICTIONARY' USING PigStorage(',');

new_videos_views = JOIN videos_views BY usuario_id, new_users BY usuario_id;
/*
(usuario_id,video_id,1,usuario_id)
(05055a341480a04f,efac34dbae7d546f,2,05055a341480a04f)
(3aca5ff7d0ccb963,efac34dbae7d546f,3,3aca5ff7d0ccb963)
(3d04a3328a3bff1c,1297e4a9e4eba68e,4,3d04a3328a3bff1c)
(737c96b151e93a3b,1297e4a9e4eba68e,5,737c96b151e93a3b)
*/

new_videos_views = JOIN new_videos_views BY video_id, new_videos BY video_id;
new_videos_views = FOREACH new_videos_views GENERATE rank_unique_users, rank_unique_videos;

rmf $DESTINATION_CSV
STORE new_videos_views INTO '$DESTINATION_CSV' USING PigStorage(',');
