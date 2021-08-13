<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<link rel="stylesheet" href="/view/css/recipe_nav.css">
<div id="sub_menu">
	<div id="search_box">
		<form name="se" method="post" action="recipe_list.jsp">
			<input type="hidden" name="cate" value="${cate }">
			<select name="sType">
				<option value="name"> 이름 </option>
				<c:if test="${sType ne 'title' }">
				<option value="title"> 제목 </option>
				</c:if>
				<c:if test="${sType eq 'title' }">
				<option value="title" selected="selected"> 제목 </option>
				</c:if>
				<c:if test="${sType ne 'ingredients' }">
				<option value="ingredients"> 재료 </option>
				</c:if>
				<c:if test="${sType eq 'ingredients' }">
				<option value="ingredients" selected="selected"> 재료 </option>
				</c:if>
			</select>
			<input type="text" name="sWord" size="10" value="${sWord}">
			<input type="submit" value="검색">
		</form>
	</div>
	<ul>
		<c:if test="${cate eq ''}">
		<li id="cate_menu"><a href="recipe_list.jsp" style="color:#f1b950"> 전체보기 </a></li>
		</c:if>
		<c:if test="${cate ne ''}">
		<li id="cate_menu"><a href="recipe_list.jsp"> 전체보기 </a></li>
		</c:if>
	<c:forEach items="${rcategorys}" var="rcategory">
		<c:if test="${cate eq rcategory}">
		<li id="cate_menu"><a href="recipe_list.jsp?cate=${rcategory}" style="color:#f1b950"> ${rcategory} </a></li>
		</c:if>
		<c:if test="${cate ne rcategory}">
		<li id="cate_menu"><a href="recipe_list.jsp?cate=${rcategory}"> ${rcategory} </a></li>
		</c:if>
	</c:forEach>
	</ul>
</div>