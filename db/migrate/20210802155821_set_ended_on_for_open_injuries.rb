class SetEndedOnForOpenInjuries < ActiveRecord::Migration[6.1]
  def change
    Injury
      .where(ended_on: nil)
      .update_all("ended_on = started_on + INTERVAL '1 year'")
  end
end
