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
require 'rails_helper'

RSpec.describe Option do
  let(:option) { create(:option) }

  it 'has a valid factory' do
    expect(option).to be_valid
  end

  it 'requires a User' do
    expect(build(:option, user: nil)).not_to be_valid
  end

  it 'requires a category' do
    expect(build(:option, category: nil)).not_to be_valid
  end

  it 'requires a value' do
    expect(build(:option, value: nil)).not_to be_valid
  end

  it 'requires a unique set of attributes' do
    new_option = build(:option,
                       user: option.user,
                       category: option.category,
                       value: option.value)
    expect(new_option).not_to be_valid
  end
end
