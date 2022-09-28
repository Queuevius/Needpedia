class AddSubjectToEmailTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :email_templates, :subject, :string
  end
end
