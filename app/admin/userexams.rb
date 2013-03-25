ActiveAdmin.register Userexam do

	# sidebar :help do
 #    "Need help? Email us at help@example.com"
 #  end

 config.per_page = 20

  actions :all, :except => [:new, :edit]
  menu :priority => 8, :label => "Results", :parent => "Exams"

  filter :exam
  filter :name
  filter :sum_point
  filter :note
  filter :created_at
  filter :updated_at
  
  index do 
    selectable_column                           
    column :name
    column "Exam" do |userexam|
      exam = link_to userexam.exam.name, admin_exam_path(userexam.exam)
      exam += " - "
      exam += link_to "Go to exam", "/" + userexam.exam.hashid.to_s
      exam
    end     

    column :password
    
    column "Email" do |userexam|
      email=userexam.email #to check if null or not null
      user_id=userexam.id #to find user
      content = userexam.password + "-" + userexam.exam.hashid.to_s + "-" + user_id.to_s
      if(userexam.email==nil) 
        form do |f|    
          f.input :class => 'name_test', :label => content             
        end
      else 
        inf = link_to userexam.email, 'javascript:void()', :class => "cd", :label => content
        inf += " - "
        inf += link_to "Edit", 'javascript:void()', :class => "editEmail"
        inf
      end
    end

    column "Point", :sum_point
    column :note       
    column "Actions" do |userexam|
      if userexam.tmp_point != nil && userexam.sum_point == nil
        link = link_to "Grade", admin_userexam_path(userexam)        
      else
        link = "<span>Grade</span>".html_safe
      end
      link += "&nbsp;&nbsp;".html_safe
      link += link_to "Show", '/admin/userexams/detail/' + userexam.id.to_s
      link += "&nbsp;&nbsp;".html_safe
      link += link_to "Delete", admin_userexam_path(userexam), :method => :delete, :data => { confirm: "Are you sure?" }
    end    
  end

  collection_action :index, :method => :get do
      scope = Userexam.getByLastExam

      @collection = scope.page(params[:page]).per(20) if params[:q].blank?
      @search = scope.metasearch(clean_search_params(params[:q]))
      @search.exam_id_eq = Exam.last.id if params[:q].blank?

      # respond_to do |format|
      #   format.html {
      #     render "my/own/template" # or "active_admin/resource/index"
      #   }
      # end
  end

  show do
  	render "show"
  end

  controller do
    def show
      @point = Userexam.find(params[:id])
      if @point.sum_point == nil
        @arr_urs_answer = Userexam.joins(:tmpanswers => {:question => :answers})
          .select("tmpanswers.question_id, questions.content, questions.type_question, tmpanswers.con_answer, answers.content as answer")
          .where("userexams.id = ?", params[:id])

      else
        redirect_to '/admin/userexams', :notice => 'This user have been finished.'
      end
    end

    def get_sum
      posts = request.POST
      posts.shift
      posts.shift
      posts.delete('commit')
      id = posts['id']
      point = posts['point'].to_i
      posts.delete('id')
      posts.delete('point')

      posts.each do |key, value|
        if value.to_i == 1
          @question = Question.select("mark").where("id = ?", key)
          point += @question[0].mark
        end
      end
      userexam = Userexam.find(id)
      if userexam.update_attributes({ "sum_point" => point })
        # @tmpanswer = Tmpanswer.where("userexam_id = ?", id)
        # @tmpanswer.each do |t|
        # 	t.destroy
        # end
        redirect_to '/admin/userexams', :notice => 'This user have been finished.'
      end
    end   

    def detail
    	@userexam = Userexam.find(params[:id])
      @infq = Question.joins(:tmpanswers).select("con_answer, content, type_question, questions.id as id")
                      .where("tmpanswers.userexam_id = ?", params[:id])

      @single_ques = Array.new
      @open_ques = Array.new
      @multi_ques = Array.new
      i = j = k = 0 # index of three array above
      @infq.each do |a|        
        #select true answer
        ans_true = Answer.select('content').where('answers.question_id = ? and answers.mark_type = ?', a['id'], 1)
        #single choice question
        if a['type_question'] == "Single choice"
          #select content of user's answer
          single = Answer.select('content').where('answers.question_id = ? and answers.id = ?', a['id'], a['con_answer'].to_i)          
          
          @single_ques[i] = Hash.new
          @single_ques[i]['qContent'] = a['content']
          @single_ques[i]['aContent'] = single[0].content
          @single_ques[i]['trueAnswer'] = ans_true[0].content
          i = i + 1
        #open question
        elsif a['type_question'] == "Open answer"
          # open = Answer.select('content').where('answers.question_id = ?', a['id'])
          
          @open_ques[j] = Hash.new
          @open_ques[j]['qContent'] = a['content']
          @open_ques[j]['aContent'] = a['con_answer']
          @open_ques[j]['trueAnswer'] = ans_true[0].content
          j = j + 1

          else #multichoice question
            userchoices = a['con_answer'].split(" ").map{ |s| s.to_i }
            userchoices.join(",")
            @multi_ques[k]=Hash.new
            @multi_ques[k]['qContent'] = a['content']# question content

            @multi_ques[k]['aContent'] = Array.new #answers of user
            multi = Answer.select('content').where('answers.question_id = ? and answers.id in (?)', a['id'], userchoices)
            for tmp in 0 ... multi.length do
              @multi_ques[k]['aContent'][tmp] = multi[tmp].content
            end

            @multi_ques[k]['trueAnswer'] = Array.new #true answers
            for tmp in 0 ... ans_true.length do
              @multi_ques[k]['trueAnswer'][tmp] = ans_true[tmp].content
            end
            k = k + 1
          end
        end               
    end
  end
end
