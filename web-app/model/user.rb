class User
  
  attr_accessor :id, :el_client
  
  def initialize user_id
    @id = user_id
  end
  
  def get_videos_history el_client
    @el_client = el_client
    query_user['videos'].map {|x| x.slice(0)}
  end
  
  def get_shows_history el_client
    @el_client = el_client
    query_user['shows'].map {|x| x.slice(0)}
  end
  
  private
  
  def query_user
    user = @el_client.search index: 'users', 
      body: { 
        query: { 
          ids: { 
            values: [@id]
          } 
        } 
      }
    user['hits']['hits'].first['_source']
  end
  
end
