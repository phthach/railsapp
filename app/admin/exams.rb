ActiveAdmin.register Exam do
  config.per_page = 20
  # form do |f|                         
  #   f.inputs "Exam Details" do     
  #     f.input :category, :prompt => "Select Category"  
  #     f.input :name                  
  #     f.input :description
  #   end                               
  #   f.buttons                         
  # end
  index do           
    selectable_column                 
    column :name do |exam|
      link_to exam.name, "/" + exam.hashid.to_s
    end                     
    column :description
    column :time_exam             
    default_actions                   
  end

  menu :priority => 6
  
  form :partial => "form" #use formtastic

  filter :category
  filter :name
  filter :description
  filter :time_exam 
  filter :created_at
  filter :updated_at

  collection_action :index, :method => :get do
      scope = Exam.getByLastCategory

      @collection = scope.page(params[:page]).per(20) if params[:q].blank?
      @search = scope.metasearch(clean_search_params(params[:q]))
      @search.category_id_eq = Category.last.id if params[:q].blank?

      # respond_to do |format|
      #   format.html {
      #     render "my/own/template" # or "active_admin/resource/index"
      #   }
      # end
  end

  show do #view link
    @exam = Exam.find(params[:id])
    render 'show'
  end
  
  controller do

    def update
      @exam = Exam.find(params[:id])
      @exam.on_answer = @exam.m_answer = @exam.o_answer = @exam.q_user = 1
      

      if @exam.update_attributes(params[:exam])
        redirect_to '/admin/exams', notice: 'Exam was successfully updated.'
      else
        render 'edit'
      end
    end

    def new
      @exam = Exam.new(:on_answer => 0, :o_answer => 0, :m_answer => 0)
    end

    def create
      @exam = Exam.new(params[:exam])
      arr =Array.new
      arr = @exam.level
      arr.shift
      arr.join(",")
      if @exam.valid?
        # create random questions

        question1 = Question.select("id").order("RAND()").limit(@exam.on_answer).where("type_question = ? AND category_id = ? AND level in (?)", "Single choice", @exam.category_id, arr);
        question2 = Question.select("id").order("RAND()").limit(@exam.m_answer).where("type_question = ? AND category_id = ? AND level in (?)", "Multiple choices", @exam.category_id, arr);
        question3 = Question.select("id").order("RAND()").limit(@exam.o_answer).where("type_question = ? AND category_id = ? AND level in (?)", "Open answer", @exam.category_id, arr);        

        @questions = question1 + question2 + question3

        respond_to do |format|
          @exam.save

          # create record examquestion
          0.upto(@questions.length - 1) do |i|
            @examquestion = Examquestion.new
            @examquestion.exam_id = @exam.id
            @exam.update_attributes({"hashid" => Digest::SHA1.hexdigest(@exam.id.to_s)})
            @examquestion.question_id = @questions[i].id
            @examquestion.save
          end

          @exam.q_user.to_i.times do 
            @userexam = Userexam.new
            @userexam.password = generate(6)
            @userexam.exam_id = @exam.id
            @userexam.save

          end

          format.html { redirect_to '/admin/exams/' + @exam.id.to_s, notice: 'Exam was successfully created.'}
          format.json { render json: @exam, status: :created, location: @exam }
          
        end
      # end#
    else
      render 'new'
    end
  end

    def edit
      @exam = Exam.find(params[:id])
      fields = Subject.joins(:categories => :exams).select("subjects.id, subjects.name").where("exams.id = ?", params[:id])
      @subject = fields[0]
      @categories_sub = Category.joins(:subject).select("categories.id, categories.name").where("subjects.id = ?", @subject.id) 
    end

    private

    def generate(length)
      chars = [*'a'..'z', *'0'..'9']
      r = ''
      length.times { r << chars[rand(36)] }
      r
    end

  end

  action_item :only => :show do
    link_to "New Exam", new_admin_exam_path
  end
end
