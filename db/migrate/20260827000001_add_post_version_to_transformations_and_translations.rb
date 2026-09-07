class AddPostVersionToTransformationsAndTranslations < ActiveRecord::Migration[6.0]
  def change
    add_column :post_transformations, :post_version_id, :bigint
    add_column :post_translations, :post_version_id, :bigint

    add_foreign_key :post_transformations, :post_versions
    add_foreign_key :post_translations, :post_versions

    add_index :post_transformations, :post_version_id
    add_index :post_translations, :post_version_id
  end
end
