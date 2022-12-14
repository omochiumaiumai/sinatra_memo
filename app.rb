# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'cgi/escape'

def json_read(file_name)
  JSON.parse(File.open(file_name).read)
end

def json_write(file_name, group, submission_details)
  File.open(file_name, 'w') do |file|
    writing_file = { group => submission_details }
    JSON.dump(writing_file, file)
  end
end

get '/' do
  json_file = json_read('memo.json')['memos']
  @json_file = json_file
  erb :index
end

get '/new' do
  erb :new
end

post '/memos' do
  @title = CGI.escapeHTML(params[:title])
  @text = CGI.escapeHTML(params[:text])
  new_memo = { id: SecureRandom.alphanumeric(6).to_s, title: @title.to_s, text: @text.to_s.gsub(/\r\n/, "\n") }
  memos_data = json_read('memo.json')

  updated_files = memos_data['memos'].unshift(new_memo)
  json_write('memo.json', 'memos', updated_files)
  redirect to('/', 301)
end

get '/memo/:id' do
  @memo_id = params[:id]
  memos_data = json_read('memo.json')['memos']
  memo_data = memos_data.select { |value| value['id'] == @memo_id }
  memo_data.each do |hash|
    @title = hash['title']
    @text = hash['text']
  end
  erb :show
end

delete '/memo/:id' do
  @memo_id = params[:id]
  memos_data = json_read('memo.json')['memos']
  memo_data = memos_data.select { |value| value['id'] == @memo_id }
  data_location = memos_data.index(memo_data[0])
  memos_data.delete_at(data_location)

  json_write('memo.json', 'memos', memos_data)
  redirect to('/', 301)
end

get '/memo/:id/edit' do
  @memo_id = params[:id]
  memos_data = json_read('memo.json')['memos']
  memo_data = memos_data.select { |value| value['id'] == @memo_id }
  @title = memo_data[0]['title']
  @text = memo_data[0]['text']
  erb :edit
end

patch '/memo/:id' do
  @memo_id = params[:id]
  @new_title = CGI.escapeHTML(params[:title])
  @new_text = CGI.escapeHTML(params[:text])

  memos_data = json_read('memo.json')['memos']
  new_memo = { id: @memo_id, title: @new_title.to_s, text: @new_text.to_s.gsub(/\r\n/, "\n") }
  old_memo = memos_data.select { |value| value['id'] == @memo_id }

  data_location = memos_data.index(old_memo[0])
  memos_data.delete_at(data_location)

  updated_files = memos_data.unshift(new_memo)
  json_write('memo.json', 'memos', updated_files)
  redirect to('/', 301)
end
