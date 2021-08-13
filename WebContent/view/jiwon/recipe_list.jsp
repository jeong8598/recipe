<%@page import="www.member.Member"%>
<%@page import="www.pagination.Pagination"%>
<%@page import="com.oreilly.servlet.MultipartRequest" %><!-- 파일업로드와 관련된클래스 -->
<%@page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %><!-- 파일이름이 동일한것이 있을떄 파일이름을 자동으로 변경해줌 -->
<%@page import="java.io.File" %>
<%@page import="java.util.Enumeration"%>
<%@page import="www.db.dao.Recipe_boardDAO"%>
<%@page import="www.db.dto.Recipe_boardDTO"%>
<%@page import="www.html.header.Header"%>
<%@page import="www.html.nav.Nav"%>
<%@page import="www.html.footer.Footer"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
Member m = new Member();

boolean login = m.isLogin(session);
if (!login)
	response.sendRedirect("/view/member/login.jsp");

request.setCharacterEncoding("utf-8");
int cpage = request.getParameter("cpage") != null ? Integer.parseInt(request.getParameter("cpage")) : 1;
int range = request.getParameter("range") != null ? Integer.parseInt(request.getParameter("range")) : 1;

Header header = new Header();
String css = header.getCss();
String js = header.getJs();
String title = header.getTitle();
String headerUrl = header.getHeaderUrl();

Nav nav = new Nav();
String menu = nav.getMenu();

Footer footer = new Footer();
String footerUrl = footer.getFooterUrl();

Recipe_boardDAO dao = new Recipe_boardDAO();
Recipe_boardDTO dto = new Recipe_boardDTO();

StringBuilder sb = new StringBuilder();

//게시글 수 쿼리문
String sql = "select count(*) total from recipe_board ";
String addSql = "";
// 검색어
String sWord = request.getParameter("sWord") != null ? request.getParameter("sWord") : "";
// 검색 종류(작성자/제목/재료)
String sType = request.getParameter("sType") != null ? request.getParameter("sType") : "";
// 카테고리(메인반찬/디저트...)
String cate = request.getParameter("cate") != null ? request.getParameter("cate") : "";

// 총 게시글 수
int listCnt = 0;
// 현재 나타내고자 하는 페이지 변수
int pager = 0;
// 보여지는 항목 수
String postNum = "5";
// 보여지는 항목 시작값 ex)항목 5개씩 보여지면 1,6,11,16,...
int index = 0;
//이동 페이지 첫번째 번호
int sPage = 0;
//이동 페이지 마지막 번호
int lPage = 0;
// 총 페이지 수
int pageCnt = 0;

if(request.getParameter("pager") != null)	//페이지값 안 넘어왔으면 첫 페이지 보여주기
	pager = Integer.parseInt(request.getParameter("pager"));
else
	pager = 1;

//항목시작값 한 페이지에 5개씩
index = pager!=1 ? ((pager-1)*5)+1 : 1;

//조회쿼리
sb.append("select ");
sb.append(dto.toString(true));
if(sType!="" || cate!=""){
	sb.append(" from (select seq, tt.* from (select rownum seq, t.* from (select * from recipe_board where ");
	if(sType!="" && cate!=""){	//검색어,카테고리 있을 때	
		if(sType.equals("name")){
			sb.append("name like '%' || ? || '%' and rcategory = ? order by rbno desc) t) tt where seq >= ?) where rownum <= ?");
			addSql = "where name like '%" + sWord + "%' and rcategory='"+ cate +"'";
		}else if(sType.equals("title")){
			sb.append("title like '%' || ? || '%' and rcategory = ? order by rbno desc) t) tt where seq >= ?) where rownum <= ?");
			addSql = "where title like '%" + sWord + "%' and rcategory='"+ cate +"'";
		}else if(sType.equals("ingredients")){
			sb.append("ingredients like '%' || ? || '%' and rcategory = ? order by rbno desc) t) tt where seq >= ?) where rownum <= ?");
			addSql = "where ingredients like '%" + sWord + "%' and rcategory='"+ cate +"'";
		}
		dao.selectAll(sb.toString(), "" + sWord + "", cate, Integer.toString(index),postNum);
	}else if(sType!=""){	//검색어 있을 때
		if(sType.equals("name")){
			sb.append("name like '%' || ? || '%' order by rbno desc) t) tt where seq >= ?) where rownum <= ?");
			addSql = "where name like '%" + sWord + "%'";
		}else if(sType.equals("title")){
			sb.append("title like '%' || ? || '%' order by rbno desc) t) tt where seq >= ?) where rownum <= ?");
			addSql = "where title like '%" + sWord + "%'";
		}else if(sType.equals("ingredients")){
			sb.append("ingredients like '%' || ? || '%' order by rbno desc) t) tt where seq >= ?) where rownum <= ?");
			addSql = "where ingredients like '%" + sWord + "%'";
		}
		dao.selectAll(sb.toString(), "" + sWord + "", Integer.toString(index),postNum);
		
	}else if(cate!=""){	//카테고리 있을 때
		sb.append("rcategory = ? order by rbno desc) t) tt where seq >= ?) where rownum <= ?");
		dao.selectAll(sb.toString(), cate, Integer.toString(index), postNum);
		addSql = "where rcategory='"+ cate +"'";
	}
}else{ //검색어,카테고리 없을 때
	sb.append(" from (select seq, tt.* from (select rownum seq, t.* from (select * from recipe_board order by rbno desc) t) tt where seq >= ?) where rownum <= ?");
	dao.selectAll(sb.toString(), Integer.toString(index), postNum);
}
//sb초기화
sb.setLength(0);

//게시물 수 가져오기
sb.append(sql);
sb.append(addSql);
listCnt = dao.count(sb.toString());

//페이지는 5개씩
pageCnt = listCnt/5;	//1~4까지는 포함되지 않음
if(listCnt%5!=0)
	pageCnt += 1;

//첫페이지,마지막페이지 구하기
sPage = pager/5;

if(pager%5==0){
	sPage = sPage>1 ? (sPage-1)*5+1 : 1;
}else{
	sPage = sPage*5+1;
}

//마지막페이지는 첫페이지+4
lPage = sPage+4;

if(lPage>pageCnt){	//마지막페이지가 총 페이지수보다 크면 총 페이지 수와 같게
	lPage = pageCnt;
}
pageContext.setAttribute("rcategorys", dao.rcategorys);
pageContext.setAttribute("list", dao.getList());
pageContext.setAttribute("pageCnt", pageCnt);
pageContext.setAttribute("sPage", sPage);
pageContext.setAttribute("lPage", lPage);
pageContext.setAttribute("pager", pager);
pageContext.setAttribute("cate", cate);
pageContext.setAttribute("sWord", sWord);
pageContext.setAttribute("sType", sType);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
<link rel="shortcut icon" href="/view/img/favicon.ico" type="image/x-icon" />
<link rel="icon" href="/view/img/favicon.ico" type="image/x-icon" />
<title><%=title%></title>
<%=css%>
<%=js%>
<!-- <script defer src="/view/js/pagination.js"></script> -->
<link rel="stylesheet" href="/view/css/recipe_list.css">
</head>
<body>
	<input type="hidden" id="color_class" value="jiwon" />
	<input type="hidden" name="url" value="/view/jiwon/recipe_list.jsp" />
 	<input type="hidden" name="listCnt" value='<%=listCnt%>' />
	<%-- <input type="hidden" name="info" value='<%=pageInfo%>' /> --%>
	<div id="wrap">
		<jsp:include page="<%=headerUrl%>" flush="true"/>
		<nav>
			<div class="base_wrap">
				<%=menu%>
			</div>
		</nav>
		<main>
			<div class="base_wrap">
				<%@ include file="recipe_nav.jsp" %> 
				<div class="contents">
					<% %>
					<div id="container">
						<h2>RecipeList</h2>
						<div id="etc"><a href="recipe_write.jsp">레시피 올리기</a></div>
						<table id="recipeList">
						<colgroup>
							<col width="12%"/>
							<col width="25%"/>
							<col width="35%"/>
							<col width="7%"/>
							<col width="5%"/>
							<col width="5%"/>
						</colgroup>
							<tr>
								<th>카테고리</th>
								<th>이미지</th>
								<th>제목</th>
								<th>이름</th>
								<th>조회수</th>
								<th>좋아요</th>
							</tr>
							<c:forEach var="dto" items="${list }">
							<tr>
								<td align="center">${dto.rcategory }</td>
								<td>
									<a href="readnum.jsp?rbno=${dto.rbno }&sWord=<%=sWord%>&sType=<%=sType%>&cate=<%=cate%>&pager=${pager}">
									<img src="/upload/img/${dto.mainimg }" width="250" height="250"/>
									</a>
								</td>
								<td><a href="readnum.jsp?rbno=${dto.rbno }">${dto.title }</a></td>
								<td>${dto.name }</td>
								<td>${dto.readnum }</td>
								<td>${dto.liked }</td>
							</tr>
							</c:forEach>
							<tr>
								<c:if test="${pageCnt ne 0 }">
	  							<td colspan="7" align="center">
								<!-- 이전페이지 이동(1페이지, 이전 그룹페이지) -->
								<!-- 이전페이지 이동 시작 -->
								<c:if test="${sPage != 1 }">
									<a href="recipe_list.jsp?pager=${sPage-1 }&sWord=<%=sWord%>&sType=<%=sType%>&cate=<%=cate%>"> &laquo; </a>
								</c:if>
								<c:if test="${sPage == 1 }"> &laquo;  </c:if>
								<c:if test="${pager != 1 }"> 
									<a href="recipe_list.jsp?pager=${pager-1 }&sWord=<%=sWord%>&sType=<%=sType%>&cate=<%=cate%>"> &lt; </a>
								</c:if>
								<c:if test="${pager == 1 }"> &lt;  </c:if>
								<!-- 이전 1페이지 이동 끝 -->
								<!-- pstart부터 pend까지 출력 -->
								<c:forEach var="i" begin="${sPage }" end="${lPage }">
									<c:if test="${pager != i }">
										<a href="recipe_list.jsp?pager=${i }&sWord=<%=sWord%>&sType=<%=sType%>&cate=<%=cate%>">${i }</a>
									</c:if>
									<c:if test="${pager == i}">
										<a href="recipe_list.jsp?pager=${i}&sWord=<%=sWord%>&sType=<%=sType%>&cate=<%=cate%>" style="color:red"> ${i} </a>
									</c:if>
								</c:forEach>
								<!-- 다음페이지 이동( 1페이지, 다음그룹페이지)  -->   
								<!-- 1페이지 다음 이동 시작 -->
								<c:if test="${pager != pageCnt }"> 
									<a href="recipe_list.jsp?pager=${pager+1 }&sWord=<%=sWord%>&sType=<%=sType%>&cate=<%=cate%>"> &gt; </a>
								</c:if>
								<c:if test="${pager == pageCnt}"> &gt; </c:if>
								<!-- 1페이지 다음 이동 끝 -->
								<!-- 다음 그룹 페이지 이동 시작 -->
								<c:if test="${lPage != pageCnt }">
									<a href="recipe_list.jsp?pager=${lPage+1 }&sWord=<%=sWord%>&sType=<%=sType%>&cate=<%=cate%>"> &raquo; </a>
								</c:if>
								<c:if test="${lPage == pageCnt }"> &raquo; </c:if>
								<!-- 다음 그룹 페이지 이동 끝 -->
								</td>
								</c:if>
							</tr> 
						</table>
					</div>
				</div>
			</div>
		</main>
		<jsp:include page="<%=footerUrl%>" flush="true"/>
	</div>
</body>
</html>