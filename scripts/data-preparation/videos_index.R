######################################################
#
# Converting a CSV to TSV (Tab-separated values) with videos meta-data
# 
# Since some texts have commas between words, a TSV seems to work better
# for this data. Plus the Pig script couldn't understand some line breaks 
# like \n... that's why we're replacing it with blank spaces.
#
######################################################

library(dplyr)

videos <- read.csv(file = '../../data/videos.csv', header = TRUE, 
                   sep = ',', stringsAsFactors = FALSE)

videos$descricao <- gsub('\n', ' ', videos$descricao)

write.table(videos, file = '../../data/videos_meta.tsv', sep = '\t',
            row.names = FALSE, quote = FALSE, col.names = TRUE)
