<%@ page pageEncoding="utf-8" contentType="text/html; charset=utf-8"%>
<%@ page import="java.io.*, java.util.*,org.apache.commons.io.*"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.disk.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>
<%@ page import="javax.servlet.*,java.text.*" %>
<%@ page import="java.sql.*"%>

<%
   Connection conn =null;

   java.util.Date tt= new java.util.Date();
   SimpleDateFormat ft = new SimpleDateFormat ("yyyy-MM-dd HH:mm:ss");
   String time = ft.format(tt).toString();
   

   //单纯显示文章的时候要用到的变量
   int articleId=20;
   String articleids=request.getParameter("articleId");
   if(articleids!=null && !articleids .equals("")){
   	  articleId = Integer.parseInt(articleids);
   }
   String now_content="";//当前文章内容
   String now_userId=request.getParameter("userId");//当前用户
   if(now_userId==null)now_userId="test";
   String mode=request.getParameter("mode");
   String picture="";//头像
   String nickname="";//昵称
   int num_content=0;//已发表文章数

   String content_title="";
   String content_time="";
   String content_userId="";//当前文章作者
   String content_belong="";//文章类别
   int love_count=0;//点赞数
   int count=0;
   
   String is_like=request.getParameter("is_like");
   if(is_like==null)
         is_like="";

   StringBuilder op_img=new StringBuilder("");
   StringBuilder articles_name=new StringBuilder("");
   StringBuilder comment_main=new StringBuilder("");
   //建立连接
   boolean flag_connect=false;
      String connectString = "jdbc:mysql://localhost:3306/blog?characterEncoding=utf-8&serverTimezone=UTC";
      try {
         Class.forName("com.mysql.jdbc.Driver");
         conn = DriverManager.getConnection(connectString, "root", "2569535507Lw");
         flag_connect=true;
      } catch (Exception e) {
         System.out.println(e.getMessage());
      }

   //建立连接后执行插入指令。将文章放入article表中
   if(flag_connect){//显示，编辑
   	  Statement stat;
      ResultSet rs=null;
      stat = conn.createStatement();
      Statement stat2=conn.createStatement();
      //根据articleId显示文章
      String fmt2="Select * From article where articleId='%d'";
      String Command2 = String.format(fmt2,articleId);
      //执行指令
      try{
         rs = stat.executeQuery(Command2);
      }catch(Exception e){}
      while(rs.next()){
            content_title=rs.getString("title");
            now_content=rs.getString("content");//文章
            content_userId=rs.getString("userId");//文章作者
            content_time=rs.getString("Time");//发表时间
            content_belong=rs.getString("belong");
            count=rs.getInt("count");
            love_count=rs.getInt("love_count");
      }
      //增加访问次数
   	  if(!now_userId.equals(content_userId)&&mode==null){
   	  	String sql="Update article set count = count + 1 where articleId='"+articleId+"'";
   	    stat.executeUpdate(sql);
   	    count++;
   	  }
      //显示人物信息
      String fmt3="Select * From user where userId='%s'";
      String Command3 = String.format(fmt3,now_userId);
      rs=null;
      try{
         rs = stat.executeQuery(Command3);
      }catch(Exception e){
      }
      while(rs.next()){
            picture = rs.getString("picture");
            if(picture==null){
                 picture="pictures/init.png";
             }else{
                 picture="files/"+now_userId+".png";
             }
            nickname = rs.getString("nickname");
      }

      String fmt3_x = "Select * From article where userId ='%s'";
      String Command3_x =  String.format(fmt3_x,now_userId);
      rs=null;
      try{
         rs = stat.executeQuery(Command3_x);
      }catch(Exception e){}
      while(rs.next()){
            num_content++;
      }

      //点赞表
      String fmt4="Select * From love where articleId='%d' and userId='%s'";
      String Command4 = String.format(fmt4,articleId,now_userId);
      //执行指令
      rs=null;
      try{
         rs = stat.executeQuery(Command4);
      }catch(Exception e){
  
      }
    
      int is_like_count=0;
      while(rs.next()){
        is_like_count=1;
      }
      
      if(is_like_count>0){
        is_like="yes";
      }else{
        is_like="no";
      }

      
      //显示编辑，删除，点赞图标
      if(now_userId.equals(content_userId)){
         op_img.append("#main_left #operation #op_img3{display: normal;}");
      }else op_img.append("#main_left #operation #op_img3{display:none;}");

      if(is_like.equals("yes")){
        op_img.append("#main_left #operation #op_img1{display: none;}");
        op_img.append("#main_left #operation #op_img2{display: normal;}");
      }else{
        op_img.append("#main_left #operation #op_img1{display: normal;}");
        op_img.append("#main_left #operation #op_img2{display: none;}");
      }
      String sql="select * from article where userId='"+now_userId+"'";
      rs=null;
      try{
         rs=stat.executeQuery(sql);
         int cnt=0;
         while(rs.next()){
            if(cnt<10){
               articles_name.append("<li><a href='report.jsp?userId="+rs.getString("userId")+"&articleId="+rs.getInt("articleId")+"'>"+rs.getString("title")+"</a></li>");
            }else if(cnt<11){
               articles_name.append("<li>...</li>");
            }
            cnt++;
         }
      }catch(Exception e){}
      //显示评论
      String sql_fmt="Select * From comment where articleId ='%d'";
      String sql_comment=String.format(sql_fmt,articleId);
      rs=null;
      ResultSet rs2=null;
      try{
         rs=stat.executeQuery(sql_comment);
         while(rs.next()){
            rs2=null;
            String comment_user = rs.getString("userId");
            String comment_text = rs.getString("content");
            String Command5 = String.format(fmt3,comment_user);
            comment_main.append("<div id=\"comment\"><div id=\"comment_img_box\"><img id=\"comment_img\" src=\"");
            rs2=stat2.executeQuery(Command5);
            while(rs2.next()){
               String comment_user_nickname = rs2.getString("nickname");
               String comment_picture = rs2.getString("picture");
               if(comment_picture==null){
                    comment_picture="pictures/init.png";
                }else{
                    comment_picture="files/"+comment_user+".png";
                }
               comment_main.append(comment_picture);
               comment_main.append("\" /> </div><div id=\"comment_user\">");
               comment_main.append(comment_user_nickname);
            }
            comment_main.append(": </div><div id=\"comment_content\">");
            comment_main.append(comment_text);
            comment_main.append("</div> <hr></div>");
         }
      }catch(Exception e){}
   }
   else out.print("连接数据库失败<br>");
%>


<!DOCTYPE  html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <link rel="stylesheet" href="css/report.css"/>
    <style>
       <%out.print(op_img);%>
    </style>
    <script>

    </script>
    <style>
        p{
            font-size:1.2em;
        }
        body {
            background: url('pictures/blog_background.jpg') no-repeat;
            background-attachment: fixed;
            background-size: 120% 120%;

        }

        #main{
            width:1000px;
            margin:0 auto;
        }
        #main_left {
            width: 70%;
            float: left;
            margin-right:5px;
            margin-left:20px;
            background-color:rgba(255,251,240,0.6);
            box-shadow:inset 5px 5px 5px rgba(111,111,111,0.8), inset -5px -5px 5px rgba(111,111,111,0.8),5px 5px 5px rgba(111,111,111,0.5), -5px -5px 5px rgba(111,111,111,0.5);
        }
        #main_left a img{

            display:inline-block;
            width:30px;
            height:30px;
            margin-right: 20px;
            opacity:0.5;
        }
        #main_left a img:hover{
            opacity:1;
        }
        #operation{
            float:right;
            padding-right: 45px;
            padding-top: 20px;
        }
        hr{width:980px;margin-left:20px;}
        #head h1{
            font-family:KaiTi;
            margin-left:20px;
        }
        #head div{
            display:inline-block;
            font-family:LiSu;
            font-size:1.2em;
        }
        #info1{
            margin-left:20px;
            float:left;
        }
        #info2 {
            float:right;
        }
        #content {
            font-family: 宋体;
            font-size: 1.2em;
            line-height: 1.4em;
            padding: 0 30px;
            word-spacing: 0.2em;
            white-space: pre-wrap;
            word-wrap: break-word;
        }
        #main_right {
            float: right;
            width: 220px;

        }
        #picture_box {
            width: 100%;
            height: 200px;
            text-align:center;
            background-color:rgba(255,251,240,0.3);
            box-shadow:inset 5px 5px 2px rgba(111,111,111,0.3), inset -5px -5px 2px rgba(111,111,111,0.3),5px 5px 2px rgba(111,111,111,0.2), -5px -5px 2px rgba(111,111,111,0.2);
        }
        #picture_box img{
            width:100px;
            height:100px;
            border:2px solid black;
            border-radius:50px;
            margin-top:20px;
        }
        #picture_box div{
            font-family:LiSu;
            font-size:1.5em;
            margin-top:8px;
        }
        #picture_box #num_article {
            font-size:0.9em;
        }
        .clearer {clear: both; font-size: 0;}
        #main_right h2{
            color: #5A5A43;
            font: bold 1.1em Tahoma,sans-serif;
            margin-top:10px;
            padding-left: 12px;
        }
        #main_right ul {
            padding: 0;
            border-top: 1px solid #EAEADA;
        }
        li {list-style: none;}
        #main_right li {
            border-bottom: 1px solid #EAEADA;
        }
        #main_right li a {
            font-size:0.8em;
            color: #554;
            display: block;
            padding: 8px 0 8px 5%;
            text-decoration: none;
            width: 95%;
        }
        #main_right li a:hover {
            background: #F0F0EB;
            color: #654;
        }


        #comment_box{
            width: 840px;
            margin-top: 20px;
            margin-left:20px;
            padding: 20px;
            background-color:rgba(255,251,240,0.6);
            box-shadow:inset 5px 5px 5px rgba(111,111,111,0.8), inset -5px -5px 5px rgba(111,111,111,0.8),5px 5px 5px rgba(111,111,111,0.5), -5px -5px 5px rgba(111,111,111,0.5);
        }
        #input_comment{
            width: 98.5%;
            margin-bottom: 20px;
            padding: 5px;
            border: 1px solid rgb(154,154,154);
        }
        #text{
            width: 98.3%;
            height: 100px;
            box-shadow: inset 1px 1px rgb(154,154,154);
            padding:6px;
            font-size: 1.5em;
            line-height:1.6em;
            font-family: 楷体;
            word-spacing: 0.2em;
        }

        #judge_box{
            text-align:right;
            margin-right: 10px;
            margin-top: 5px;
        }
        #comment{
            margin-bottom: 20px;
        }
        #comment_img_box{
            display: inline-block;
            border: 1px solid black;
            width: 60px;
            height:60px;
            border-radius: 30px;
            position: relative;
        }
        #comment_img{
            display: inline-block;
            width: 60px;
            height: 60px;
            border-radius: 30px;
        }
        #comment_user{
            display: inline-block;
            margin-left:10px;
            position: relative;
            top:-20px;
            font-size: 1.18em;
        }
        #comment_content{
            margin-top:5px;
            line-height:1.2em;
            text-indent:1em;
            font-size: 1.3em;
            font-family: 楷体;
            word-spacing: 0.2em;
            word-wrap: break-word;
        }
        #comment hr{width:800px}
    </style>
</head>

<body>
    <div id="main">
        <div id="head">
            <h1><%=content_title%></h1>
            <div id="info1">类别:<%=content_belong%> &nbsp;&nbsp; 浏览次数:<%=count%>&nbsp;&nbsp;点赞数:<%=love_count%></div>
            <div id="info2">发表时间:<%=content_time%></div>
            <div class="clearer"></div>
        </div>
        <hr>
        <div id="main_left">
            <div id="operation">
                <a href="handler-show.jsp?userId=<%=now_userId%>&articleId=<%=articleId%>&is_like=<%=is_like%>&mode=zan"><img  id="op_img1" src="pictures/zan1.png"/></a>
                <a href="handler-show.jsp?userId=<%=now_userId%>&articleId=<%=articleId%>&is_like=<%=is_like%>&mode=zan"><img  id="op_img2" src="pictures/zan2.png"/></a>
                <a href="Edit.jsp?userId=<%=now_userId%>&articleId=<%=articleId%>"><img id="op_img3" src="pictures/write.png"/></a> 
                <a href="handler-show.jsp?userId=<%=now_userId%>&articleId=<%=articleId%>&is_like=<%=is_like%>&mode=delete"><img id="op_img3" src="pictures/delete.png"/></a>

            </div>
            <div class="clearer"></div>
            <div id="content_box">
                <pre id="content"><%=now_content%></pre>
            </div>
        </div>
        <div id="main_right">
            <div id="picture_box">
                <img src=<%=picture%> />
                <div><a href="home.jsp?user_name=<%=now_userId%>"><%=nickname%></a></div>
                <div id="num_article">已发表文章数：<%=num_content%></div>
            </div>
            <h2>我的文章:</h2>
         <ul>
            <%=articles_name%>
         </ul>
        </div>
        <div class="clearer"></div>
        <div id="comment_box">
            <div id="input_comment">
                <form class="form" action="handler-show.jsp?articleId=<%=articleId%>&userId=<%=now_userId%>&mode=comment" method="post">
                    <textarea id="text" name="text" placeholder="请输入内容"></textarea>
                    <div id="judge_box">
                        <input type="submit" id="judge" name="judge" value="评论">
                    </div>
                </form>
            </div>

            <%=comment_main%>          
        </div>
    </div>

</body>
</html>