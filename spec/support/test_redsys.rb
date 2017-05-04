require 'sinatra/base'

class TestRedsys < Sinatra::Base
  get ':25443/canales' do
    json_response 200, 'responses.json'
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE) + '/fixtures/' + file_name, 'rb')
  end
end
