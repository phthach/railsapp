class MaintestController < HomeController
  skip_before_filter :authorize

  def test_exam
    if session[:username] == nil
      redirect_to '/public/500.html'
    else
      @exam = Exam.find_by_hashid(params[:hashid])

      if @exam != nil
      	# get all questions
        @userexam = Userexam.find_by_password(session[:password])
      	@questions = Examquestion.joins(:question).select("questions.id, questions.content, questions.type_question")
      			.where("examquestions.exam_id = ?", @exam.id)

      	@arr = Array.new
      	i = 0

      	# create @arr include question, answer, ...
      	if @questions != nil
      		@questions.each do |q|
      			@arr[i] = Hash.new
      			@arr[i]['id'] = q.id
      			@arr[i]['type_question'] = q.type_question
      			answer = Answer.joins(:question).select("answers.id, answers.content").where("answers.question_id = ?", q.id)
      			@arr[i]['question'] = q.content
      			@arr[i]['answer'] = Hash.new
      			if answer != nil
      				answer.each do |a|
      					@arr[i]['answer'][a.id] = a.content
      				end
      			end
      			i = i + 1
      		end
      	end

      	respond_to do |format|
      		format.html
      	end
      else
        redirect_to "/public/404.html"
      end
    end
  end

  def get_point
    if session[:username] == nil
      redirect_to '/500.html'
    else
        params = request.POST
        params.shift
        params.shift
        id = params[:id] #id of userexam
        exam = Exam.find_by_hashid(params[:hashid])
        params.shift
        params.shift
        params.delete('commit')         

        point = 0
        check_open = false

        userexam = Userexam.find(id)       

        params.each do |key, value|
          question = Question.select("mark, type_question").where("id = ?", key)          
          tmpanswer = Tmpanswer.new #
          tmpanswer.userexam_id = userexam.id
          tmpanswer.question_id = key
          # Multiple choices
          if question[0].type_question == "Multiple choices"
            ans = ""
            for j in 0 ... value.length
              ans += value[j].to_s + " "
            end
            tmpanswer.con_answer = ans
            tmpanswer.save

            value.join(",")
            answer = Answer.select("mark_type").where("id in (?)", value)
            check = 1
            if answer.length > 1
              for i in 0 ... answer.length
                check &= answer[i].mark_type # x &= y => x = x & y
              end
              if check == 1
                point += question[0].mark
              end
            end

          # Open answer
          elsif question[0].type_question == "Open answer"
            check_open = true
            answer = Answer.joins(:question)
              .select("questions.id")
              .where("questions.id = ?", key)

            #tmpanswer = Tmpanswer.new
            # tmpanswer.userexam_id = userexam.id
            # tmpanswer.question_id = answer[0].id
            tmpanswer.con_answer = value
            tmpanswer.save

          # Single choice
          else 
            answer = Answer.select("mark_type").where("id = ?", value)
            if answer[0] != nil && answer[0].mark_type == 1
                point += question[0].mark
            end    
            tmpanswer.con_answer = value.to_s
            tmpanswer.save
          end                              
        end

        userexam.update_attributes({"sum_point" => point}) if check_open == false

      # save tmp_point into table userexam
      time_end = Time.now
      time_test = time_end - userexam.time_start

      if time_test > (exam.time_exam * 60)
        time_finish = time_test - (exam.time_exam * 60)
        time_to_min = (time_finish / 60).floor
        if (time_to_min > 0)
          flash_alert = 'You have completed. But you are ' + time_to_min.to_s + ' minute(s) late!'
          userexam.update_attributes({ "tmp_point" => point, "time_end" => time_end, "note" => time_to_min.to_s + " minute(s) late!" })
        else
          flash_alert = 'You have completed on time!'
          userexam.update_attributes({ "tmp_point" => point, "time_end" => time_end, "note" => "Completed on time!" })
        end
      else
        userexam.update_attributes({ "tmp_point" => point, "time_end" => time_end, "note" => "Completed on time!" })
        flash_alert = 'You have completed on time!'
      end
      session[:username] = nil
      session[:password] = nil
      redirect_to "/" + exam.hashid, :alert => flash_alert
    end
  end
end
