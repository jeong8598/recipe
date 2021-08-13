//허용되는 이미지 형식
var imgExt = ["JPG","JPEG","GIF","PNG"];
var chkExt = false;

function check(){
	var cate = $('select[name="rcategory"] option:selected').val(); 
	var title = document.getElementById("title");
	var intro = document.getElementById("intro");
	var mainFileName = $("#addMainImg").val();
	var fileName = $(".addImg").val();
	 // 확장자 체크
	//substring(시작[,끝]) -> 부분 문자열 잘라내기
	//lastIndexOf(찾는 문자열) -> 뒤에서부터 찾는 문자열의 위치. 없으면 -1반환
	//toUpperCase() -> 모든 영문자 대문자로
	
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
	var exit = false;
	$(".ingredients").each(function(){
		var ingre = $(this).val();
		if(ingre.length==0){
			alert("재료를 모두 입력하세요");
			$(this).focus();
			return false;
			exit = true;
		}
	});
	$(".content").each(function(){
		var cont = $(this).val();
		if(cont.length==0){
			alert("레시피를 모두 입력하세요");
			$(this).focus();
			return false;
			exit = true;
		}
	});
	$(".addImg").each(function(){
		var fileName = $(this).val();
		var ext = getExt(fileName);
	});
	

	if(exit) return false;
	if(!checkExt){
		alert("지원하지 않는 파일입니다.");
		return false;
	}
}

function chkExt(ext){
	for(i=0 ; i<imgExt.length ; i++){
		if(ext == imgExt[i]){
			checkExt = true;
			return checkExt;
			break;
		}
	}
}
function getExt(fileName){
	return fileName.substring(fileName.lastIndexOf(".")+1).toUpperCase();
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
var num = 2;
/*요리순서추가*/
function addContent(){
	var input = '<div class="contInner"><div class="imgUpload"><img class="img" width="200" height="200" alt=""><div class="imgBtn"><input type="file" class="addImg" required="required" name="imgStep'+num+'"/></div></div>';
	input += '<div class="contText"><textarea cols="50" rows="8" name="content"  class="content" placeholder="레시피를 순서대로 작성해주세요."></textarea></div>';
	input += '<div class="BtnBox"><input type="button" class="delContent" value="X" /></div></div>';
	$('.cont_container').append(input);
	
	$(".addImg").on("change",function(){
		var index = $(".addImg").index(this);
		readImg(index,this);
	});
	num++;
};
/*요리순서삭제*/
function delContentBtn() {
	$('.cont_container').on('click', 'input.delContent', function(){
		var content_num = $("textarea[name='content']").length;	//요리과정 개수
		if(content_num>1){	//개수 한개 이상일 때만 삭제
			var obj = $(this);
			var parObj = obj.parent().parent();
	
			obj.remove();
			parObj.remove();
		}
	});
};
/*메인 이미지 미리보기*/
function readMainImg(input){
	if(input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function (e) {
        	$('.mainImg').attr('src', e.target.result);
        }
        reader.readAsDataURL(input.files[0]);
    }
}
//이미지 미리보기
function readImg(index,input) {
	if (input.files && input.files[0]) {
		var reader = new FileReader();
		reader.onload = function (e) {
			$('.img').eq(index).attr('src', e.target.result);  
		}
		reader.readAsDataURL(input.files[0]);
	}
}

$(".addImg").on("change",function(){
	var index = $(".addImg").index(this);
	readImg(index,this);
});

delIngreBtn();
delContentBtn();