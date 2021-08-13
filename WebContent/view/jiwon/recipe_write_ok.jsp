<%@page import="java.util.Arrays"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="www.db.dao.Recipe_boardDAO"%>
<%@page import="com.oreilly.servlet.MultipartRequest" %><!-- 파일업로드와 관련된클래스 -->
<%@page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %><!-- 파일이름이 동일한것이 있을떄 파일이름을 자동으로 변경해줌 -->
<%@page import="java.io.File" %>
<%@page import="java.util.Enumeration"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
/* 이미지저장 */
String path = request.getSession().getServletContext().getRealPath("/upload/img/");
int size = 1024*1024*10;
String encoding = "utf-8";

MultipartRequest multi = new MultipartRequest(request,path,size,encoding,new DefaultFileRenamePolicy());

String title = multi.getParameter("title") != null ? multi.getParameter("title") : "";
String name = multi.getParameter("name") != null ? multi.getParameter("name") : "";
String rcategory = multi.getParameter("rcategory") != null ? multi.getParameter("rcategory") : "";
String mainimg = "";
String img = "";
String intro = multi.getParameter("intro") != null ? multi.getParameter("intro") : "";
String[] content = multi.getParameterValues("content");
String[] ingredients = multi.getParameterValues("ingredients");

//파일이름 가져오기
Enumeration fileNames = multi.getFileNames();

StringBuilder builder = new StringBuilder();

Map<String, String> imgs = new HashMap<String, String>();

int i = 0;
while(fileNames.hasMoreElements()){
	String parameter = (String)fileNames.nextElement();
	
	String fileName = multi.getFilesystemName(parameter);
	//System.out.println(parameter);
	if(i>=0){
		imgs.put( parameter, fileName);
	}
	i++;
}
// 이미지 순서 없이 넘어오므로 키로 정렬
Object[] imgList = imgs.keySet().toArray();
Arrays.sort(imgList);
// 이미지 개수
int len = imgList.length;

for (int j=0; j<len; j++) {
    System.out.println(j + " : "+ imgList[j]);
    System.out.println(imgs.get(imgList[j]));
}

Recipe_boardDAO dao = new Recipe_boardDAO();

//sql문 만들기
builder.append("insert into recipe_board(rbno,title,name,rcategory,mainimg,");

if (len > 0) {
	builder.append("img,intro,content,ingredients,writeday,addtype) values(s_recipe_board.nextval,?,?,?,?,?,?,?,?,sysdate,'u')");
	for (int j=0 ; j<len ; j++) {
		if (j < 1){
			img = imgs.get(imgList[j]);
		}else if(imgList[j].equals("mainImg")){
			mainimg = imgs.get(imgList[j]);
		}else{
			img += "," + imgs.get(imgList[j]);
		}
	}
//out.print("제목 : "+title+" 이름 : "+name+" 카테고리: "+rcategory+" 메인 : "+mainimg+" 이미지 : "+img+" 소개 : "+intro+" 요리순서 : "+content+" 재료 : "+ingredients);
}else{
	builder.append("intro,content,ingredients,writeday,addtype) values(s_recipe_board.nextval,?,?,?,?,?,?,?,sysdate,'u')");
}


int r = 0;
if (imgs.size() > 0)
	r = dao.insert(builder.toString(),title,name,rcategory,mainimg,img,intro,String.join("##",content),String.join(",", ingredients));
else
	r = dao.insert(builder.toString(),title,name,rcategory,mainimg,intro,String.join("##",content),String.join(",", ingredients));
 
response.sendRedirect("recipe_list.jsp");
%>