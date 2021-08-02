class SetEndedOnForOpenLoans < ActiveRecord::Migration[6.1]
  def change
    Loan
      .where(ended_on: nil)
      .update_all("ended_on = started_on + INTERVAL '2 year'")
  end
end
