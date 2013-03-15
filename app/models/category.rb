class Category < ActiveRecord::Base
  scope :getByLastSubject, lambda { where("subject_id = ?", Subject.last.id) }
  attr_accessible :description, :name, :subject_id

  belongs_to :subject
  has_many :questions, :dependent => :destroy
  has_many :exams, :dependent => :destroy

  validates :name, :presence => true, :length => { :maximum => 255 }
  validates :subject_id, :presence => true
end
