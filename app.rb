# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'cgi/escape'
require 'pg'

get '/' do
  conn = PG.connect(dbname: 'memo_app')
  @memos = conn.exec("SELECT * FROM memos")
  erb :index
end

get '/new' do
  erb :new
end

post '/memos' do
  memo_id = SecureRandom.alphanumeric(6).to_s
  @title = CGI.escapeHTML(params[:title])
  @text = CGI.escapeHTML(params[:text])

  conn = PG.connect(dbname: 'memo_app')
  conn.exec("INSERT INTO memos(id,title,text) VALUES ('#{memo_id}','#{@title}', '#{@text}')")

  redirect to('/', 301)
end

get '/memo/:id' do
  @memo_id = params[:id]

  conn = PG.connect(dbname: 'memo_app')
  memos = conn.exec("SELECT * FROM memos WHERE id = '#{@memo_id}'").values
  memos.each do |array|
    @title = array[1]
    @text = array[2]
  end
  erb :show
end

delete '/memo/:id' do
  memo_id = params[:id]
  conn = PG.connect(dbname: 'memo_app')
  conn.exec("DELETE FROM memos WHERE id = '#{memo_id}'")
  redirect to('/', 301)
end

get '/memo/:id/edit' do
  @memo_id = params[:id]
  conn = PG.connect(dbname: 'memo_app')
  memos = conn.exec("SELECT * FROM memos WHERE id = '#{@memo_id}'").values
  memos.each do |array|
    @title = array[1]
    @text = array[2]
  end
  erb :edit
end

patch '/memo/:id' do
  memo_id = params[:id]
  new_title = CGI.escapeHTML(params[:title])
  new_text = CGI.escapeHTML(params[:text])

  conn = PG.connect(dbname: 'memo_app')
  conn.exec("UPDATE memos SET title = '#{new_title}', text = '#{new_text}' WHERE id = '#{memo_id}' ")
  redirect to('/', 301)
end
