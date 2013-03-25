//= require active_admin/base
//= require rich
$(document).ready(function() {
	$("#subject_id").change(function() {
		var id = $(this).val();
		
		$.ajax ({
			type: "POST",
			url: "/ajax/make_ajax_category",
			data: {id: id},
			cache: false,
			success: function(html) {
				$("#question_category_id, #exam_category_id").html(html);
			}
		});
	});
});

$(document).ready(function() {
	var id = 1
	var arr_num = new Array();
	
	$("#add_new_answer").click(function() {

		id += 1;
		
		var answer_name = "answer" + id;
		var link_answer_name = "link_answer" + id;
		var name = "mark_type" + id;
		var t_name = "content" + id;

		$("#answer").append("<br /><br /><div id='" + answer_name + "'><label class=' label'>Answer<abbr title='required'>*</abbr></label>" +
			"<textarea class=\"answer_content\" rows='10' name='answer[][content]'></textarea>&nbsp;&nbsp;" + 
				"<a href='javascript:void(0);' id='" + link_answer_name + "'>Remove this answer</a><br />" +
				"<input class=\"rad_answer\" type='radio' name='answer_rad[][" + name + "]' value='0' checked='true' />&nbsp;Incorrect&nbsp;&nbsp;" +
				"<input type='radio' name='answer_rad[][" + name + "]' value='1' />&nbsp;Correct&nbsp;<br />");

	});

	$("#question_type_question").change(function() {
		$('#answer').html("");
		var id = $(this).val();
		if (id == "Single choice" || id == "Multiple choices") {
			$('#answer').html("<br /><label class='' label'>Answer<abbr title='required'>*</abbr></label>" +
			"<textarea class=\"answer_content\" rows='10' name='answer[][content]'></textarea><br />" +
				"<input class=\"rad_answer\" type='radio' name='answer_rad[][mark_type1]' value='0' checked='true' />&nbsp;Incorrect&nbsp;&nbsp;" +
				"<input type='radio' name='answer_rad[][mark_type1]' value='1' />&nbsp;Correct<br />");
			$('#add_new_answer').removeClass('hide-add-answer');
		} else if (id == "Open answer") {
			$('#answer').html("<label class='' label'>Answer<abbr title='required'>*</abbr></label>" +
				"<textarea class='answer_content' rows='10' name='answer[][content]'></textarea><br />");
			$('#add_new_answer').addClass('hide-add-answer');
		}
	});

	$("a[id^=link_answer]").live("click", function() {
			$(this).parent().remove();
			
	});

});

$(document).ready(function(){
	var pass;
	var link;
	var email;
	var user_id;

  	$(".name_test").live('change',function(){	//textbox
    	content=$(this).attr("label");
    	email=$(this).val().trim();
    	if (email=="") return true;
    	var testEmail = /^[A-Z0-9._%+-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i;
		if (testEmail.test(email)){
	    	$(this).parent().replaceWith('<td><a href="javascript:void()" class="cd" label='+content+'>'+email+'</a> - <a href="javascript:void()" class="editEmail">Edit</a></td>');   	    	
	    	arr=content.split("-");
	    	pass=arr[0];
	    	link=arr[1];
	    	user_id=arr[2];
	    	$.ajax ({
				type: "POST",
				url: "/mail/insertEmail",
				data: {email: email, user_id: user_id}, //pass to find user & save email
				success: function(html) {
					alert("Save email success!");
				}		
			});
	    }
	    else 
	    	alert("Valid e-mail please...!"); 
	});

  	$(".cd").live('click', function(){ //click to send mail with link and password
  		content=$(this).attr("label");
    	email=$(this).text();
    	arr=content.split("-");
	    pass=arr[0];
	    link=arr[1];
    	$.ajax ({
			type: "POST",
			url: "/mail/sendMail",
			data: {e: email, p: pass, l: location.host+"/"+link},
			success: function(html) {
				alert("Send mail success!");
			}				
		}); 	      
  	});

  	// edit email when click edit link
  	var preElm;
  	$(".editEmail").live('click',function(){
  		preElm = $(this).parent();
  		content = $(this).prev().attr("label");
  		oldEmail = $(this).prev().text();
  		$(this).parent().replaceWith('<td><input class="name_test" label="'+content+'"></input> - <a href="javascript:void()" class="returnPrev">Return</a></td>');
  	});

  	$('.returnPrev').live('click', function(){
		$(this).parent().replaceWith(preElm);  		
  	});
  	
});

$(document).ready(function(){
	$('.ansLater').click(function(){
		ide = $(this).attr('value');
    	if($(this).children().hasClass('icon-star-empty')){
    		$(this).find('i').replaceWith('<i class="icon-star"></i>');
			$('#notAnsBody').append("<a id='ID"+ide+"' href=#"+ide+">Quesion "+ide+"</a><br>");
		}
		else{
			$(this).find('i').replaceWith('<i class="icon-star-empty"></i>');
			$('#ID'+$(this).attr('value')).next().detach();
			$('#ID'+$(this).attr('value')).detach();
		} 
  	});
});