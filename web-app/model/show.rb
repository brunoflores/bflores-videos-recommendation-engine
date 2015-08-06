class Show
  
  def get_top_recs el_client, history
    recs = el_client.search index: 'shows', 
      body: { 
        query: { 
          bool: { 
            should: [ { match: { indicators: history.to_s } } ],
            must_not: [ { ids: { values: history } } ]
          }
        } 
      }
    recs['hits']['hits']
  end
  
  def similar_to el_client, show_id
    meta = el_client.search index: 'shows', 
      body: { 
        query: { 
          ids: { 
            values: [show_id]
          } 
        },
        fields: ['titulo', 'descricao']
      }
    recs = el_client.search index: 'shows', 
      body: { 
        query: {
          bool: {
            should: [
              multi_match: {
                query: meta['hits']['hits'].first['fields']['descricao'],
                fields: ['titulo', 'descricao^2']
              }
            ],
            must_not: [ { ids: { values: [show_id] } } ]
          }
        }
      }
    recs['hits']['hits']
  end
  
end
