function check(){
	var exit = false;
	var cate = $('select[name="rcategory"] option:selected').val(); 
	var title = document.getElementById("title");
	var intro = document.getElementById("intro");
	if(cate=="0") {
		alert("카테고리를 선택하세요");
	    return false;
	}
	if(title.value.length==0){
		alert("제목을 입력하세요");
		title.focus();
		return false;
	}
	if(intro.value.length==0){
		alert("음식소개를 입력하세요");
		intro.focus();
		return false;
	}
	$(".ingredients").each(function(){
		var ingre = $(this).val();
		if(ingre.length==0){
			alert("재료를 모두 입력하세요");
			$(this).focus();
			exit = true;
		}
	});
	$(".content").each(function(){
		var cont = $(this).val();
		if(cont.length==0){
			alert("레시피를 모두 입력하세요");
			$(this).focus();
			exit = true;
		}
	});
	$(".img").each(function(){
		var img = $(this).attr("src");
		if(typeof img === "undefined"){
			alert("이미지를 등록하세요");
			exit = true;
			return false;
		}
	});
	if(exit) return false;
	return true;
}

/*재료추가*/
function addIngre() {
	var input = '<span class="el"><input type="text" name="ingredients" class="ingredients" placeholder="예) 돼지고기 400g" /> <input type="button" class="delIngre" value="X" /></span>';

	$(input).appendTo($('.ingre_container'));
};

/*재료삭제버튼*/
function delIngreBtn() {
	$('.ingre_container').on('click', 'input.delIngre', function(){
		var ingre_num = $("input[name='ingredients']").length;	//재료 개수
		if(ingre_num>1){	//개수 한개 이상일 때만 삭제
			var obj = $(this);
			var prevObj = obj.prev();
			var parObj = obj.parent();
	
			obj.remove();
			prevObj.remove();
			parObj.remove();
		}
	});
};

var num = $(".contInner").length+1;

/*요리순서추가*/
function addContent(){
	var input = '<div class="contInner"><div class="imgUpload"><img class="img" width="200" height="200" alt=""><div class="imgBtn"><input type="file" class="addImg" required="required" name="imgStep'+num+'"/></div></div>';
	input += '<div class="contText"><textarea cols="50" rows="8" name="content"  class="content" placeholder="레시피를 순서대로 작성해주세요."></textarea></div>';
	input += '<div class="BtnBox"><input type="button" class="delContent" value="X" /></div></div>';
	
	$('.cont_container').append(input);
	
/*	$(document).on("change",".addImg",function(){
		var index = $(".contInner").index($(this).parents(".contInner"));
		console.log(index);
		readImg(index,this);
	});*/

	num++;
};

/*요리순서삭제*/
function delContentBtn() {
	$('.cont_container').on('click', 'input.delContent', function(){
		var content_num = $("textarea[name='content']").length;	//요리과정 개수
		if(content_num>1){
			var chk = confirm("삭제하시겠습니까?");
			if(chk){
				var obj = $(this);
				var parObj = obj.parent().parent();
				var index = $(".delContent").index(this);
				
				putImgIndex(0,index);
				
				obj.remove();
				parObj.remove();
			}
		}
	});
};

//삭제하거나 변경하는 이미지 인덱스를 hidden값 delImgIndex나 chgImgIndex에 넣어주기
function putImgIndex(chk,index){
	var src = $(".img").eq(index).attr("src")
	//alert(src);
	if(typeof src != "undefined"){
		var name = imgNameSplit(src);
		var i = equalIndex(name);
	}
	var imgIndex;
	var item;
	if(chk!=1){
		item=$("input[name=delImgIndex]");
	}else{
		item=$("input[name=chgImgIndex]");
	}
	if(typeof i != "undefined"){
		if(typeof item.val() == "undefined" || item.val() =="" ||item.val() == null){
			imgIndex = i;
			item.val(imgIndex);
		}else{
			imgIndex = item.val();
			imgIndex += ","+i;
			item.val(imgIndex);
		}
	}
}
//저장된 이미지명에서 넘어온 이미지명과 같은 인덱스번호 찾기
function equalIndex(name){
	var savedImg = $("input[name=savedImg]").val();
	var saveImgList = savedImg.split(",");
	for(i=0; i<saveImgList.length ; i++){
		if(saveImgList[i]===name){
			return i;
			break;
		}
	}
}
//src에서 경로없이 이미지명만 가져오기
function imgNameSplit(src){
	//alert(src)
	if(src.includes("/")){
		var name = src.split("/");
		var length = name.length;
		return name[length-1];
	}
}
/*메인 이미지 미리보기*/
function readMainImg(input){
	if(input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function (e) {
        	$('.mainImg').attr('src', e.target.result);
        }
        reader.readAsDataURL(input.files[0]);
        //imgUpdate("mainimg",input);

    }
}
//이미지 미리보기
function readImg(index,input) {
	if (input.files && input.files[0]) {
		var reader = new FileReader();
		reader.onload = function (e) {
			$(".img").eq(index).attr("src", e.target.result);  
		}
		reader.readAsDataURL(input.files[0]);
		putImgIndex(1,index);
		//imgUpdate(index,input);
	}
}

$(document).on("change",".addImg",function(){
	var index = $(".contInner").index($(this).parents(".contInner"));
	console.log(index);
	//imgUpdate(1,index,this);
	readImg(index,this);
});

$(".mainimgChg").on("click",function(){
	var input = "<input type='file' class='addMainImg' name='mainImg' onchange='readMainImg(this)'/>";
	$("#mainImgBtn").html(input);
	
});
	
$(document).on("click",".imgChg",function(){
	var index = $(".contInner").index($(this).parents(".contInner"));
	var input = '<input type="file" class="addImg" required="required" name="imgStep'+index+'"/>';
	num++;
	$(".imgBtn").eq(index).html(input);
});

delIngreBtn();
delContentBtn();
