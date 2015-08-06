######################################################
#
# Merging files to make a CSV ready to index users
# into ElasticSearch
#
######################################################

library(dplyr)

videos_views <- read.csv(file = '../../data/video_views.csv', header = TRUE)
videos <- read.csv(file = '../../data/videos.csv', header = TRUE)

videos_views <- tbl_df(videos_views)
videos <- tbl_df(videos)

merged <- merge(videos_views, videos, by = 'video_id')
merged <- tbl_df(merged)
merged <- select(merged, video_id, usuario_id, programa_id)
merged <- group_by(merged, usuario_id) %>% 
        summarise(videos = toString(video_id), 
                  programas = toString(programa_id))

write.table(merged, file = '../../data/users_meta.csv', sep = ';',
            row.names = FALSE, quote = FALSE, col.names = TRUE)
