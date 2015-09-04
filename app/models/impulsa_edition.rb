class ImpulsaEdition < ActiveRecord::Base
  has_many :impulsa_edition_categories
  has_many :impulsa_projects, through: :impulsa_edition_categories
  has_many :impulsa_edition_topics
  
  has_attached_file :legal
  has_attached_file :schedule_model
  has_attached_file :activities_resources_model
  has_attached_file :requested_budget_model
  has_attached_file :monitoring_evaluation_model

  validates :name, presence: true

  validates_attachment_content_type :legal, content_type: ["application/pdf", "application/x-pdf"]
  validates_attachment_content_type :schedule_model, content_type: [ "application/vnd.ms-excel", "application/msexcel", "application/x-msexcel", "application/x-ms-excel", "application/x-excel", "application/x-dos_ms_excel", "application/xls", "application/x-xls", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.oasis.opendocument.spreadsheet" ]
  validates_attachment_content_type :activities_resources_model, content_type: [ "application/vnd.ms-excel", "application/msexcel", "application/x-msexcel", "application/x-ms-excel", "application/x-excel", "application/x-dos_ms_excel", "application/xls", "application/x-xls", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.oasis.opendocument.spreadsheet" ]
  validates_attachment_content_type :requested_budget_model, content_type: [ "application/vnd.ms-excel", "application/msexcel", "application/x-msexcel", "application/x-ms-excel", "application/x-excel", "application/x-dos_ms_excel", "application/xls", "application/x-xls", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.oasis.opendocument.spreadsheet" ]
  validates_attachment_content_type :monitoring_evaluation_model, content_type: [ "application/vnd.ms-excel", "application/msexcel", "application/x-msexcel", "application/x-ms-excel", "application/x-excel", "application/x-dos_ms_excel", "application/xls", "application/x-xls", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.oasis.opendocument.spreadsheet" ]
end