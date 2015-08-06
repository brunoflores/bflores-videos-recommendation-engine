class Video
  
  def get_top_recs el_client, history
    recs = el_client.search index: 'videos', 
      body: { 
        query: { 
          function_score: {
            query: {
              filtered: {
                query: {
                  bool: { 
                    must: [ { match: { indicators: history.to_s } } ],
                    must_not: [ { ids: { values: history } } ]
                  }
                },
                filter: {
                  exists: {
                    field: 'titulo'
                  }
                }
              }
            },
            functions:[ { random_score: { seed: 20 } } ],
            score_mode: 'sum'
          }
        } 
      }
    recs['hits']['hits']
  end
  
  def get_recs_by_category el_client, history
    categories = el_client.search index: 'videos', 
      body: { 
        query: { 
          ids: { values: history }
        },
        fields: ['categoria']
      }
    unique = []
    categories['hits']['hits'].each do |category|
      name = category['fields']['categoria'].first
      unique << name unless unique.include? name
    end
    categories = []
    unique.each do |category|
      recs = el_client.search index: 'videos', 
        body: { 
          query: { 
            bool: {
              should: [ 
                { match: { indicators: { query: history.to_s } } }, 
                { match: { categoria: { query: category } } } 
              ],
              must_not: [ { ids: { values: history } } ]
            }
          }
        }
      categories << { :title => category, :videos => recs['hits']['hits'] }
    end
    categories
  end
  
  def get_tags el_client, history
    tags_search = el_client.search index: 'videos',
      body: {
        query: {
          filtered: {
            query: {
              bool: {
                must: [ { match: { indicators: history.to_s } } ],
                must_not: [ { ids: { values: history } } ]
              }
            },
            filter: {
              exists: {
                field: 'tags'
              }
            }
          }
        },
        fields: ['tags']
      }
    tags = []
    tags_search['hits']['hits'].each do |video|
      tags = tags | video['fields']['tags']
    end
    tags
  end
  
  def similar_to el_client, video_id, history
    must_not = history | [video_id]
    tags = el_client.search index: 'videos', 
      body: { 
        query: { 
          ids: { 
            values: [video_id]
          } 
        },
        fields: ['tags']
      }
    recs = el_client.search index: 'videos', 
      body: { 
        query: { 
          bool: { 
            must: [ { match: { tags: tags['hits']['hits'].first['fields'].to_s } } ],
            must_not: [ { ids: { values: must_not } } ]
          }
        }
      }
    recs['hits']['hits']
  end
  
end
