<%@ page language="java" import="java.util.*,java.sql.*" 
		contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<!doctype html>
<html lang="zh">
<head>
	<meta charset="UTF-8">
	<link rel="stylesheet" type="text/css" href="css/login.css">
	<title>登录界面</title>
	<style>
		.b {
			background-image: url("pictures/login.jpg");
			color:#7a1b47;
			background-repeat: no-repeat;
		}
	</style>
</head>
<%
	
	// 设置编码格式
	request.setCharacterEncoding("utf-8");
	// 连接数据库
	String connectString = "jdbc:mysql://localhost:3306/blog?characterEncoding=utf-8&serverTimezone=UTC";
	Class.forName("com.mysql.jdbc.Driver");
	Connection conn = DriverManager.getConnection(connectString, "root", "2569535507Lw");
	Statement statement = conn.createStatement() ;

	String userId = request.getParameter("userId") ;
	String pass = request.getParameter("pass") ;
	boolean userIdHint = false,passHint=false ;

		
	// 如果是登录
	if ( request.getParameter("login")!=null ) {
		if ( userId.equals("admin") && pass.equals("123") )
			response.sendRedirect("root.jsp"); 
		String sql="SELECT* FROM user WHERE userId=\'"+userId+"\'" ;
		ResultSet rs=statement.executeQuery(sql) ;
		rs.last() ;
		if ( rs.getRow()==0 ){
			userIdHint = true ;
			%>
				<style  type="text/css">
					#userId::-webkit-input-placeholder{color: red;font-weight: 1000;}
					#userId:-moz-placeholder{color: red;font-weight: 1000;}
					#userId::-moz-placeholder{color: red;font-weight: 1000;}
					#userId:-ms-input-placeholder{color: red;font-weight: 1000;}

				</style>
			<%
		}else {
			rs.first() ;
			if ( !pass.equals(rs.getString("password")) ){
				passHint = true;
				%>
					<style  type="text/css">
						#pass::-webkit-input-placeholder{color: red;font-weight: 1000;}
						#pass:-moz-placeholder{color: red;font-weight: 1000;}
						#pass::-moz-placeholder{color: red;font-weight: 1000;}
						#pass:-ms-input-placeholder{color: red;font-weight: 1000;}
					</style>
				<%
			}
			else{
				String name = java.net.URLEncoder.encode(userId,"utf-8") ;
				String url="home.jsp?user_name=" + name ;
				response.sendRedirect(url);
			} 
		}
	}
	// 如果是注册
	if (request.getParameter("register")!=null){
		response.sendRedirect("register.jsp"); 
	}

%>
<body class="b">
	<div class="htmleaf-container">
		<div class="wrapper">
			<div class="container">
				<h1>登录</h1>
				
				<form class="form" name="form" action="index.jsp" method="post">
					<input type="text" id="userId" placeholder=
							<%=userIdHint==true?"用户不存在" : "请输入用户名"%> 
							name="userId" onkeyup="value=value.replace(/[^\w\.\/]/ig,'')"
					>
					<input type="password" id="pass" placeholder=
							<%=passHint==true?"密码错误" : "请输入密码"%>
							name="pass"
					>
					<button type="submit" id="login-button" name="login">登录</button>
					<button type="submit" id="register-button" name="register">注册</button>
				</form>
			</div>
				<li></li>
				<li></li>
				<li></li>
				<li></li>
				<li></li>
				<li></li>
				<li></li>
				<li></li>
				<li></li>
				<li></li>

		</div>
	</div>
</body>
</html>