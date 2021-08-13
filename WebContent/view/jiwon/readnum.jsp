<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*" %>
<%@page import="www.db.dao.Recipe_boardDAO"%>
<%
	request.setCharacterEncoding("utf-8");
	Recipe_boardDAO dao = new Recipe_boardDAO();
	String rbno = request.getParameter("rbno");
	String sWord = request.getParameter("sWord") != null ? request.getParameter("sWord") : "";
	String sType = request.getParameter("sType") != null ? request.getParameter("sType") : "";
	String cate = request.getParameter("cate") != null ? request.getParameter("cate") : "";
	int pager = request.getParameter("pager") != null ? Integer.parseInt(request.getParameter("pager")) : 1;
	
	String sql = "update recipe_board set readnum=readnum+1 where rbno=?";
	dao.update(sql,rbno);
	
	response.sendRedirect("recipe_content.jsp?rbno="+rbno+"&pager="+pager+"&sWord="+sWord+"&sType="+sType+"&cate="+cate);
%>