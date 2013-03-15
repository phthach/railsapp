class Question < ActiveRecord::Base
  scope :getByLastCategory, lambda { where("category_id = ?", Category.last.id) }
  
  attr_accessible :category_id, :content, :mark, :type_question, :level

  belongs_to :category
  has_many :answers, :dependent => :destroy
  has_many :examquestions, :dependent => :destroy
  has_many :exams, :through => :examquestions
  has_many :tmpanswers, :dependent => :destroy
  
  validates :category_id, :presence => true
  validates :content, :presence => true
  validates :mark, :presence => true, :numericality => {:greater_than => 0}
  validates :type_question, :presence => true 

end