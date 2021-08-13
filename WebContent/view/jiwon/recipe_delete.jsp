<%@page import="www.db.dto.Recipe_boardDTO"%>
<%@page import="java.io.File"%>
<%@page import="com.oreilly.servlet.MultipartResponse"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="www.db.dao.Recipe_boardDAO"%>
<%
String path = request.getSession().getServletContext().getRealPath("/upload/img/");

String rbno = request.getParameter("rbno");
File file;
StringBuilder builder = new StringBuilder();

Recipe_boardDAO dao = new Recipe_boardDAO();
Recipe_boardDTO dto = new Recipe_boardDTO();
//메인이미지,이미지 조회
builder.append("select ");
builder.append(dto.toString(true));
builder.append(" from recipe_board where rbno = ?");
dao.select(builder.toString(), rbno);

dto = dao.getDto();
String img = dto.getImg();
String[] imgs = img.split(",");
String mainimg = dto.getMainimg();
//이미지 삭제
for(String i :imgs){
	new File(path + i).delete();
}
//메인이미지 삭제
if(mainimg!=null){
	new File(path + mainimg).delete();
}
//초기화
builder.setLength(0);

//글삭제
builder.append("delete from recipe_board where rbno=?");
int i = dao.delete(builder.toString(),rbno);

response.sendRedirect("recipe_list.jsp");

%>