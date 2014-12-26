#require 'bundler/setup'
#require 'roar/representer/json'
#require 'roar/representer/feature/hypermedia'
require 'webmachine'

#require './resources/session'
#require './resources/user'
require './resources/product'
#require './resources/category'

Webmachine.routes do
  add ['products'], ProductResource
  add ['products', :id], ProductResource
end.run

#   app.routes do
# #    add ['trace', '*'], Webmachine::Trace::TraceResource
# #    add ['sessions', '*'], SessionResource
# #    add ['users', :id], UserResource
# #    add ['users'], UserResource
#
#     add ['products', :id], ProductResource
#     add ['products'], ProductResource
#
# #    add ['notes', '*'], NoteResource
# #    add ['notes', :id], NoteResource
#     #add ['tasks', :task_id, 'notes'], NoteResource
#   end
