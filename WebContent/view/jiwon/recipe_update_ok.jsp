<%@page import="www.db.dto.Recipe_boardDTO"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Arrays"%>
<%@page import="java.util.ArrayList"%>
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
File file;
MultipartRequest multi =new MultipartRequest(request,path,size,encoding,new DefaultFileRenamePolicy());
String rbno = multi.getParameter("rbno") != null ? multi.getParameter("rbno") : "";
String title = multi.getParameter("title") != null ? multi.getParameter("title") : "";
String name = multi.getParameter("name") != null ? multi.getParameter("name") : "";
String rcategory = multi.getParameter("rcategory") != null ? multi.getParameter("rcategory") : "";
String intro = multi.getParameter("intro") != null ? multi.getParameter("intro") : "";
String img = "";	//이미지명
String savedImg ="";	//저장된 이미지명
String[] content = multi.getParameterValues("content");
String[] ingredients = multi.getParameterValues("ingredients");
String mainimg = "";	//저장되어있는 메인이미지명
String newMain = multi.getParameter("newMain");	//변경된 메인이미지명
String delImgIndex = multi.getParameter("delImgIndex"); 	//삭제한 이미지명
String chgImgIndex = multi.getParameter("chgImgIndex"); 	//변경한 이미지명

Recipe_boardDAO dao = new Recipe_boardDAO();
Recipe_boardDTO dto = new Recipe_boardDTO();
StringBuilder sb = new StringBuilder();

//저장된 메인이미지명/이미지명 조회하기
sb.append("select ");
sb.append(dto.toString(true));
sb.append(" from recipe_board where rbno = ?");
dao.select(sb.toString(), rbno);
sb.setLength(0);	//초기화

dto = dao.getDto();
mainimg = dto.getMainimg();	//저장된 메인이미지명 담기
savedImg = dto.getImg();	//저장된 이미지명 담기

//파일이름 가져오기
Enumeration fileNames = multi.getFileNames();
//메인이미지인지 요리과정이미지인지 구분하기 위해 
//key에는 넘어오는 파라미터명 value에는 파일명 담기위해 hashmap 생성
Map<String, String> imgs = new HashMap<String, String>();
//새로운 이미지 리스트 만들기 위해 생성
ArrayList<String> setList = new ArrayList<String>();

int i=0;
while(fileNames.hasMoreElements()){	//넘어온이미지가 있으면
	String parameter = (String)fileNames.nextElement();
	String fileName = multi.getFilesystemName(parameter);
	//System.out.println(parameter);
	if(i>=0){
		imgs.put( parameter, fileName);
	}
	i++;
}

//이미지 순서 없이 넘어오므로 키로 정렬
Object[] imgList = imgs.keySet().toArray();
Arrays.sort(imgList);

//넘어온 이미지 개수
int len = imgList.length;

for(int j=0; j<len; j++) {
 System.out.println(j + " : "+ imgList[j]);
 System.out.println(imgs.get(imgList[j])); 
}
 
if(!newMain.isEmpty()){ //메인이미지가 바뀌었을때
	file = new File(path + mainimg);
	if(file.exists())
		file.delete();	//저장된 메인이미지 삭제
}
 
//저장된이미지를 array리스트에 넣기
String[] savedImgs = savedImg.split(",");
for(String s:savedImgs){
	setList.add(s);
}

//1.바뀐 이미지가 있으면 그 개수만큼 저장된 이미지 인덱스에 새로 들어온 이미지를 넣어주기
//2.지운 이미지가 있으면 그 개수 만큼 저장된 이미지 인덱스를 삭제
//3.넘어온 이미지가 바뀐이미지 개수보다 더 들어왔다면 뒤에 추가해준다.
	
int cLen = 0;	//바뀐 이미지 개수 변수
int dLen = 1;	//지운 이미지 개수 변수

//1.이미지가 바뀌었을때
if(!chgImgIndex.isEmpty()){
	String[] chgs = chgImgIndex.split(",");
	Arrays.sort(chgs);	//바뀐 이미지 순서 정렬
	cLen = chgs.length;	
	
	for(int j = 0 ; j<cLen ; j++){	
		file = new File(path+savedImgs[Integer.parseInt(chgs[j])]);
		if(file.exists())
			file.delete();	//바뀐이미지 파일 삭제
		// 이미지 바뀐 순서에 넘어온 이미지명으로 값 바꾸기
		setList.set(Integer.parseInt(chgs[j]),imgs.get(imgList[j]));
	}
} 

//2.삭제된 이미지가 있을 때
if(!delImgIndex.isEmpty()){
	String[] dels = delImgIndex.split(",");
	dLen = dels.length;
	//
	for(int d = 0 ; d<dLen ; d++){
		file = new File(path+savedImgs[Integer.parseInt(dels[d])]);
		if(file.exists())
			file.delete();	//삭제한 이미지 파일 삭제
		//리스트에서도 삭제
		setList.remove(Integer.parseInt(dels[d]));
	}
}
out.print("cLen"+cLen+"len"+len);
//3. 바뀐이미지개수보다 넘어온개수가 크다면 뒤에 추가해주기
for(int j=cLen ; j<len ;j++){
	if(imgList[j].equals("mainImg")){
		mainimg = imgs.get(imgList[j]);
	}else{
		setList.add(imgs.get(imgList[j]));
	}
}

int r = 0;
sb.append("update recipe_board set title=? ,rcategory=? ,intro=? ,content=?, ingredients=?");
if(len>0){	// 넘어온 이미지 있을 떄
	sb.append(", img=?, mainimg=? where rbno=? and name=?");
	r = dao.update(sb.toString(),title,rcategory,intro,String.join("##",content),String.join(",", ingredients),String.join(",", setList),mainimg,rbno,name);
}else{	//넘어온 이미지 없을 때
	sb.append(" where rbno=? and name=?");
	r = dao.update(sb.toString(), title,rcategory,intro,String.join("##",content),String.join(",", ingredients),rbno,name);
	System.out.println(sb.toString());
}


response.sendRedirect("recipe_content.jsp?rbno="+rbno);
%>