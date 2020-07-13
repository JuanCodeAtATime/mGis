class Facility < ApplicationRecord
  strip_attributes
  belongs_to :facility_group
  belongs_to :creator, class_name: "User"
  has_many :facility_projects, dependent: :destroy
  has_many :projects, through: :facility_projects
  has_many :tasks, through: :facility_projects
  has_many :task_types, through: :tasks
  has_many :comments, as: :resource, dependent: :destroy, class_name: 'ActiveAdmin::Comment'
  accepts_nested_attributes_for :comments, reject_if: :reject_comment

  validates_presence_of :facility_name, :address, :point_of_contact, :phone_number, :email

  enum status: [:inactive, :active].freeze

  def as_json(options=nil)
    json = super(options)
    json.merge(
      facility_group_name: self.facility_group.try(:name),
      creator: self.creator.as_json
    ).as_json
  end

  def reject_comment(comment)
    comment['body'].blank?
  end

  def start_date
    tasks.where(start_date: tasks.select('MIN(start_date)')).first.try(:start_date)
  end

  def end_date
    tasks.where(due_date: tasks.select('MAX(tasks.due_date)')).first.try(:due_date)
  end
end
