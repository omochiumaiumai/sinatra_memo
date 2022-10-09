# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'cgi/escape'

get '/' do
  json_file = JSON.parse(File.open('memo.json').read)['memos']
  @json_file = json_file
  erb :index
end

get '/new' do
  erb :new
end

post '/memos' do
  @title = CGI.escapeHTML(params[:title])
  @text = CGI.escapeHTML(params[:text])
  new_memo = { 'id' => SecureRandom.alphanumeric(6).to_s, 'title' => @title.to_s, 'text' => @text.to_s.gsub(/\r\n/, "\n") }
  memos_data = JSON.parse(File.open('memo.json').read)

  updated_files = memos_data['memos'].unshift(new_memo)
  File.open('memo.json', 'w') do |file|
    writing_file = { 'memos' => updated_files }
    JSON.dump(writing_file, file)
  end
  redirect to('/', 301)
end

get '/memo/:id' do
  @memo_id = params[:id]
  memos_data = JSON.parse(File.open('memo.json').read)['memos']
  memo_data = memos_data.select { |value| value['id'] == @memo_id }
  memo_data.each do |hash|
    @title = hash['title']
    @text = hash['text']
  end
  erb :show
end

delete '/memo/:id' do
  @memo_id = params[:id]
  memos_data = JSON.parse(File.open('memo.json').read)['memos']
  memo_data = memos_data.select { |value| value['id'] == @memo_id }
  data_location = memos_data.index(memo_data[0])
  memos_data.delete_at(data_location)

  File.open('memo.json', 'w') do |file|
    writing_file = { 'memos' => memos_data }
    JSON.dump(writing_file, file)
  end
  redirect to('/', 301)
end

get '/memo/:id/edit' do
  @memo_id = params[:id]
  memos_data = JSON.parse(File.open('memo.json').read)['memos']
  memo_data = memos_data.select { |value| value['id'] == @memo_id }
  @title = memo_data[0]['title']
  @text = memo_data[0]['text']
  erb :edit
end

patch '/memo/:id' do
  @memo_id = params[:id]
  @new_title = CGI.escapeHTML(params[:title])
  @new_text = CGI.escapeHTML(params[:text])

  memos_data = JSON.parse(File.open('memo.json').read)['memos']
  new_memo = { 'id' => @memo_id, 'title' => @new_title.to_s, 'text' => @new_text.to_s }
  old_memo = memos_data.select { |value| value['id'] == @memo_id }

  data_location = memos_data.index(old_memo[0])
  memos_data.delete_at(data_location)

  updated_files = memos_data.unshift(new_memo)
  File.open('memo.json', 'w') do |file|
    writing_file = { 'memos' => updated_files }
    JSON.dump(writing_file, file)
  end
  redirect to('/', 301)
end
