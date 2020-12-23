<%@ page language="java" import="java.util.*,java.sql.*" 
         contentType="text/html; charset=utf-8"
%>
<%@ page import="java.io.*,org.apache.commons.io.*"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.disk.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>
<%
response.setHeader("Cache-Control","no-cache"); 
response.setHeader("Pragma","no-cache"); 
response.setDateHeader ("Expires", -1); 
%>
<%
    request.setCharacterEncoding("utf-8");
    String mode=request.getParameter("mode");
    if(mode==null){
        mode="1";
    }
    String user_name = request.getParameter("user_name");
    if(user_name!=null){
        user_name = java.net.URLDecoder.decode(user_name,"utf-8");
    }
    if(user_name==null){
        user_name = "15352013";
    }
    String picture="";//头像是否存在
    String name="";//博客名

    String sql = "";//数据库查询语句

    Integer pgno = 0;//当前页数
    Integer pgcnt = 4;//每页显示文章数
    String param = request.getParameter("pgno");
    if(param !=null&&!param.isEmpty()){
        pgno = Integer.parseInt(param);
    }
    //这里连接数据库
    String connectString = "jdbc:mysql://localhost:3306/blog?characterEncoding=utf-8&serverTimezone=UTC";
    Class.forName("com.mysql.jdbc.Driver");
    Connection con=DriverManager.getConnection(connectString, "root", "2569535507Lw");
    Statement stmt=con.createStatement();
    
    //查找用户
    sql="select * from user where userId='"+user_name+"'";
    ResultSet rs=stmt.executeQuery(sql);
    while(rs.next()){
        name=rs.getString("nickname");//获取博客名
        picture=rs.getString("picture");//用于判断是否已经上传过头像
    }
    rs.close();
%>
<%
    if(mode.equals("1")){
        sql="select * from article where userId='"+user_name +"'";
    }else if(mode.equals("4")) {//学习类
        sql="select * from article where belong = '学习' ";
    }else if(mode.equals("5")) {//随笔类
        sql="select * from article where belong = '随笔' ";
    }else if (mode.equals("6")) {//科普类
        sql="select * from article where belong = '科普' ";
    }else if (mode.equals("7")) {//美食类
        sql="select * from article where belong = '美食' ";
    }
    StringBuilder articles=new StringBuilder("");
    int cnt = 0;
    //获取文章
    if(mode.equals("1")||mode.equals("4")||mode.equals("5")||mode.equals("6")||mode.equals("7")){
        rs=stmt.executeQuery(sql);
        while(rs.next()){
            if(cnt>=pgno*pgcnt&&cnt<(pgno+1)*pgcnt){
                articles.append("<h1><a href='report.jsp?userId="+user_name+"&articleId="+rs.getString("articleId")+"'>"+rs.getString("title")+ "</a>");
                if(rs.getString("userId").equals(user_name)){
                    articles.append("<a href='handler.jsp?mode=-2&articleId="
                    +rs.getString("articleId")+"&user_name="+user_name
                    +"'><img src='pictures/delete.png'/></a>");
                }
                articles.append("</h1><div class='date'>"+rs.getString("Time")
                        +"<label style='float:right'>浏览次数："+rs.getInt("count")
                        +"</label></div><p>"+rs.getString("content")+"</p>");
            }
            cnt++;
        }
        rs.close();
    }
    stmt.close();
    con.close();
    if(picture==null){
        picture="pictures/默认.jpg";
    }else{
        picture="files/"+user_name+".png";
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>My Blog</title>
    <meta charset="utf-8" />
    <META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE"> 
    <META HTTP-EQUIV="Expires" CONTENT="-1">
    <link rel="stylesheet" href="css/bg_bubbles.css"/>
    <link rel="stylesheet" href="css/foot.css"/>
    <link rel="stylesheet" href="css/home_head.css"/>
    <link rel="stylesheet" href="css/home_main_left.css"/>
    <link rel="stylesheet" href="css/home_main_right.css"/>
    <link rel="stylesheet" href="css/modify.css"/>
    <style>
        body{
            background: #E7E7E2 url('pictures/blog_background.jpg') no-repeat center top;
            color: #444;
            font: normal 62.5% Tahoma,sans-serif;
            padding-top: 64px;
        }
        .out{
            background: url('pictures/container.jpg') no-repeat center bottom;
            padding-bottom: 64px;
        }
        .inner{
            border: 2px solid #D7D7D2;
            background: #FFF;
            font-size: 1.2em;
            margin: 0 auto;
            padding: 10px;
            width: 780px;
        }
        h1,h2,h3 {padding-top: 6px; color: #553; margin-bottom: 4px;}
        .main {
            background: url('pictures/main.gif') repeat-y;
            border-top: 4px solid #FFF;
            padding: 8px 12px 0 0;
            min-height:700px;
        }
        .clearer {clear: both; font-size: 0;}
    </style>
</head>
<body>
    <div class="out">
        <div class="inner">
            <!--这是头部，有头像和个人博客的名字-->
            <div class="head" style="background-color: whitesmoke">
                <img src="<%=picture%>" id="head_img"/>
                <h2 id="head_name"><%=name%></h2>
            </div>
            <!--这是个人博客的菜单-->
            <div class="head_menu">
                <ul class="setting">
                    <li><img src="pictures/setting.png" />
                        <ul>
                            <li class="list"><a href="index.jsp">注销</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
            <!--这里是正文内容，左边为操作栏，右边为文章-->
            <div class="main">
                <div class="main_left">
                    <h2>个人博客</h2>
                    <ul>
                        <li class="list"><a href="home.jsp?mode=1&user_name=<%=user_name%>">个人主页</a></li>
                        <li><a href="write.jsp?mode=1&userId=<%=user_name%>">写文章</a></li>
                    </ul>
                    <h2>他人博客浏览</h2>
                    <ul>
                        <li><a href="home.jsp?mode=4&user_name=<%=user_name%>">学习</a></li>
                        <li><a href="home.jsp?mode=5&user_name=<%=user_name%>">随笔</a></li>
                        <li><a href="home.jsp?mode=6&user_name=<%=user_name%>">科普</a></li>
                        <li><a href="home.jsp?mode=7&user_name=<%=user_name%>">美食</a></li>
                    </ul>
                </div>
                <div class="main_right">
<%  if(mode.equals("2")){ %>
                    <div class="modify_img">
                        <form form name="fileupload" action="handler.jsp"  method="POST" enctype="multipart/form-data">
                            <input type="hidden" name="user_name" value="<%=user_name%>">
                            新的头像：<br><input type="file" name="new_img" required="required" accept = 'image/gif,image/jpeg,image/jpg,image/png,image/svg,image/bmp'>
                            <br><br>
                            <input type="submit" name="save" value="保存">
                        </form>
                        <form action="home.jsp?mode=1" method="post">
                            <input type="hidden" name="user_name" value="<%=user_name%>">
                            <input type="submit" name="quit" value="取消">
                        </form>
                    </div>
<%  }else if(mode.equals("3")){%>
                    <div class="modify_name">
                        <form action="handler.jsp?mode=3" method="post">
                            <input type="hidden" name="user_name" value="<%=user_name%>">
                            新的博客名：<input type="text" name="new_name" required="required">
                            <br><br>
                            <input type="submit" name="save" value="保存">
                        </form>
                        <form action="home.jsp?mode=1" method="post">
                            <input type="hidden" name="user_name" value="<%=user_name%>">
                            <input type="submit" name="quit" value="取消">
                        </form>
                    </div>
<% }else if(mode.equals("1")||mode.equals("4")||mode.equals("5")||mode.equals("6")||mode.equals("7")){
        out.print(articles);
        if(cnt==0&&mode.equals("1")){%>
            <div style="margin: 100px 100px 100px 140px;font-size: 18px"><p>你还没有发表任何文章</p><p>点击左侧写文章吧!!</p></div>
        <%}else if(cnt==0){%>
            <div style="margin: 100px 100px 100px 140px;font-size: 18px"><p>没有相关类型文章!</p></div>
        <%}
        int num=0;
        while(cnt>0){
            num++;
            cnt=cnt-4;
        }%>
        <div id="page">
            <%if(pgno!=0){%>
            <a href="home.jsp?mode=<%=mode%>&user_name=<%=user_name%>&pgno=<%=pgno-1%>">上一页</a>
            <%}%><div><%
                for(int i=1;i<=num;i++){
                    if(i==pgno+1){
                        out.print("<span>"+i+"</span>");
                    }else{
                        out.print("<a href='home.jsp?mode="+mode+"&user_name="+user_name+"&pgno="+(i-1)+"'>"+i+"</a>");
                    }
                }%>
            </div>
            <%if(pgno!=num-1&&num!=0){%>
            <a href="home.jsp?mode=<%=mode%>&user_name=<%=user_name%>&pgno=<%=pgno+1%>">下一页</a>
            <%}%>
        </div>
    <%}%>
                </div>
                <div class="clearer">&nbsp;</div>
            </div>

        </div>
    </div>
    <!--这是背景动画-->
    <ul class="bg-bubbles">
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
    </ul>
</body>
</html>