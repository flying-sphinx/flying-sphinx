class FlyingSphinx::Configure::Cache
  def initialize(connection)
    @connection = connection
  end

  def md5_for(path)
    file = json.detect { |file| file['key'] == path }
    file && file['md5']
  end

  private

  attr_reader :connection

  def json
    @json ||= MultiJson.load connection.get('/').body
  end
end
