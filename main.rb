require 'sinatra'
require 'slim'
require 'sass'
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || File.join("sqlite3://",settings.root,"development.db"))

class Robot
  include DataMapper::Resource
  
  property :id, Serial
  property :top, Integer, :default => proc { |m,p| 1+rand(6) }
  property :middle, Integer, :default => proc { |m,p| 1+rand(4) }
  property :bottom, Integer, :default => proc { |m,p| 1+rand(5) }
end

DataMapper.finalize

get '/styles.css' do
  scss :styles
end

get '/application.js' do
  content_type 'text/javascript'
  render :str, :javascript, :layout => false
end

get '/' do
  @robots = Robot.all
  slim :index
end

get '/robot/:id' do
 slim :robot, Robot.get(params[:id])
end

post '/robot' do
  robot = Robot.create
  if request.xhr?
    slim :robot, { :layout => false, :locals => { :robot => robot }}
  else
    redirect to('/')
  end
end

delete '/robot/:id' do
  robot = Robot.get(params[:id]).destroy
  redirect to('/') unless request.xhr?
end

__END__

@@layout
doctype html
html
  head
    meta charset="utf-8"
    title Robot Factory
    link rel="shortcut icon" href="/fav.ico"
    link href="http://fonts.googleapis.com/css?family=Megrim|Ubuntu&amp;v2" rel='stylesheet'
    link rel="stylesheet" media="screen, projection" href="/styles.css"
    script src="http://cdn.rightjs.org/right.js"
    script src="/application.js"
    /[if lt IE 9]
      script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"
  body
    img#waiting src="https://s3.amazonaws.com/daz4126/waiting.gif"
    == yield
    footer role="contentinfo"
      p Building Quality Robots since 2011

@@index
h1 Robot Factory
form.build action="/robot" method="POST"
  input.button type="submit" value="Build A Robot!"
-if @robots.any?
  ul#robots
  - @robots.each do |robot|
    ==slim :robot, :locals => { :robot => robot }
-else
  h2 You Need To Build Some Robots!

@@robot
li.robot
  img src="https://s3.amazonaws.com/daz4126/top#{robot.top}.png"
  img src="https://s3.amazonaws.com/daz4126/middle#{robot.middle}.png"
  img src="https://s3.amazonaws.com/daz4126/bottom#{robot.bottom}.png"
  form.destroy action="/robot/#{robot.id}" method="POST"
    input type="hidden" name="_method" value="DELETE"
    input type="submit" value="×"

@@javascript
Xhr.options.spinner = 'waiting'
"form.destroy".onSubmit(function(event) {
   this.parent().fade();
   event.stop();
   this.send();
 });
"form.build".onSubmit(function(event) {
 event.stop();
 this.send({
   onSuccess: function(xhr) {
   $('robots').insert(xhr.responseText);
  }
 });
});


@@styles
html,body,div,span,object,iframe,h1,h2,h3,h4,h5,h6,p,blockquote, pre,abbr,address,cite,code,del,dfn,em,img,ins,kbd,q,samp,small,strong,sub,sup,var,b,i,dl,dt, dd,ol,ul,li,fieldset,form,label,legend,table,caption,tbody,tfoot,thead,tr,th,td,article, aside, canvas, details,figcaption,figure,footer,header,hgroup,menu,nav,section, summary,time,mark,audio,video {
  margin:0;
  padding:0;
  border:0;
  outline:0;
  font-size:100%;
  vertical-align:
  baseline;
  background:transparent;
  line-height:1;
}
body{font-family:ubuntu,sans;}
footer {
  display:block;
  margin-top:20px;
  border-top:3px solid #4b947d;
  padding:10px;
}
h1 {
  color:#95524C;
  margin:5px 40px;
  font-size:72px;
  font-weight:bold;
  font-family:Megrim,sans;
}
.button {
  background:#4b7194;
  color:#fff;
  text-transform:uppercase;
  border-radius:12px;
  border:none;
  font-weight:bold;
  font-size:16px;
  padding: 6px 12px;
  margin-left:40px;
  cursor:pointer;
  &:hover{background:#54A0E7;}
}
#robots {
  list-style:none;
  overflow:hidden;
  margin:20px;
}
#waiting{display:none;position:absolute;left:200px;top:100px;}
.robot {
  float:left;
  width:100px;
  padding:10px 0;
  position:relative;
  form {
    display:none;
    position:absolute;
    top:0;
    right:0;
  }
  &:hover form {
    display:block;
  }
  form input {
    background:rgba(#000,0.7);
    padding:0 4px;
    color:white;
    cursor:pointer;
    font-size:32px;
    font-weight:bold;
    text-decoration:none;
    border-radius:16px;
    line-height:0.8;
    border:none;
  }
  img {
    display:block;
    padding:0 10px;
  }
}
