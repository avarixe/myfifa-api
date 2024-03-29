# frozen_string_literal: true

# == Schema Information
#
# Table name: options
#
#  id       :bigint           not null, primary key
#  category :string
#  value    :string
#  user_id  :bigint
#
# Indexes
#
#  index_options_on_user_id                         (user_id)
#  index_options_on_user_id_and_category_and_value  (user_id,category,value) UNIQUE
#
FactoryBot.define do
  factory :option do
    user
    category { Option::CATEGORIES.sample }
    sequence(:value) { |n| "Value #{n}" }
  end
end
