require 'rails_helper'

RSpec.describe TableRowsController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:team) { FactoryBot.create(:team, user: user) }
  let(:competition) { FactoryBot.create(:competition, team: team) }
  let(:stage) { FactoryBot.create(:stage, competition: competition) }

  let(:application) {
    Doorkeeper::Application.create!(
      name: Faker::Company.name,
      redirect_uri: "https://#{Faker::Internet.domain_name}"
    )
  }
  let(:token) {
    Doorkeeper::AccessToken.create!(
      application: application,
      resource_owner_id: user.id
    )
  }

  describe 'GET #index' do
    it 'requires a valid token' do
      get stage_table_rows_url(stage)
      assert_response 401
    end

    it 'returns all Table Rows of select Stage' do
      FactoryBot.create_list :table_row, 3, stage: stage
      FactoryBot.create :table_row

      get stage_table_rows_url(stage),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(stage.table_rows.reload.to_json)
    end
  end

  describe 'GET #show' do
    it 'requires a valid token' do
      table_row = FactoryBot.create :table_row, stage: stage
      get table_row_url(table_row)
      assert_response 401
    end

    it 'returns Table Row JSON' do
      table_row = FactoryBot.create :table_row, stage: stage

      get table_row_url(table_row),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(table_row.to_json)
    end
  end

  describe 'POST #create' do
    before do |test|
      unless test.metadata[:skip_before]
        post stage_table_rows_url(stage),
             headers: { 'Authorization' => "Bearer #{token.token}" },
             params: { table_row: FactoryBot.attributes_for(:table_row) }
      end
    end

    it 'requires a valid token', skip_before: true do
      post stage_table_rows_url(stage),
           params: { table_row: FactoryBot.attributes_for(:table_row) }
      assert_response 401
    end

    it 'returns Table Row JSON' do
      expect(json).to be == JSON.parse(TableRow.last.to_json)
    end
  end

  describe 'PATCH #update' do
    it 'requires a valid token', skip_before: true do
      table_row = FactoryBot.create :table_row, stage: stage
      patch table_row_url(table_row),
            params: { table_row: FactoryBot.attributes_for(:table_row) }
      assert_response 401
    end

    it 'rejects requests from other Users', skip_before: true do
      table_row = FactoryBot.create :table_row
      patch table_row_url(table_row),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { table_row: FactoryBot.attributes_for(:table_row) }
      assert_response 403
    end

    it 'returns updated Table Row JSON' do
      table_row = FactoryBot.create :table_row, stage: stage
      patch table_row_url(table_row),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { table_row: FactoryBot.attributes_for(:table_row) }
      expect(json).to be == JSON.parse(table_row.reload.to_json)
    end
  end

  describe 'DELETE #destroy' do
    it 'requires a valid token', skip_before: true do
      table_row = FactoryBot.create :table_row, stage: stage
      delete table_row_url(table_row)
      assert_response 401
    end

    it 'rejects requests from other Users', skip_before: true do
      table_row = FactoryBot.create :table_row
      delete table_row_url(table_row),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response 403
    end

    it 'removes the Table Row' do
      table_row = FactoryBot.create :table_row, stage: stage
      delete table_row_url(table_row),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      expect { table_row.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
