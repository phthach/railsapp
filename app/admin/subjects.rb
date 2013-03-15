ActiveAdmin.register Subject do
	config.per_page = 20
  menu :priority => 3

  index do     
    selectable_column                       
    column :name         
    column :description            
    default_actions                
  end

  action_item :only => :show do
    link_to "New Subject", new_admin_subject_path
  end

end
