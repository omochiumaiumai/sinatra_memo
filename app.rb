# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'cgi/escape'
require 'pg'

def db_select
  PG.connect(dbname: 'memo_app')
end

def execute(sql, params)
  conn = db_select
  conn.exec_params(sql, params)
end

def memo_create(id, title, text)
  sql = 'INSERT INTO memos (id, title, text) VALUES ($1, $2, $3)'
  params = [id, title, text]
  execute(sql, params)
end

def memo_edit(id, title, text)
  sql = 'UPDATE memos SET title = $1, text = $2 WHERE id = $3'
  params = [title, text, id]
  execute(sql, params)
end

def memo_select(id)
  sql = 'SELECT * FROM memos WHERE id = $1'
  params = [id]
  execute(sql, params)
end

get '/' do
  conn = db_select
  @memos = conn.exec('SELECT * FROM memos')
  erb :index
end

get '/new' do
  erb :new
end

post '/memos' do
  memo_id = SecureRandom.alphanumeric(6).to_s
  @title = CGI.escapeHTML(params[:title])
  @text = CGI.escapeHTML(params[:text])

  memo_create(memo_id, @title, @text)

  redirect to('/', 301)
end

get '/memo/:id' do
  memo_id = params[:id]
  @memo = memo_select(memo_id).values.first
  erb :show
end

delete '/memo/:id' do
  memo_id = params[:id]
  conn = db_select
  conn.exec("DELETE FROM memos WHERE id = '#{memo_id}'")
  redirect to('/', 301)
end

get '/memo/:id/edit' do
  memo_id = params[:id]
  @memo = memo_select(memo_id).values.first
  erb :edit
end

patch '/memo/:id' do
  memo_id = params[:id]
  new_title = CGI.escapeHTML(params[:title])
  new_text = CGI.escapeHTML(params[:text])

  memo_edit(memo_id, new_title, new_text)

  redirect to('/', 301)
end
