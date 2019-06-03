# == Schema Information
#
# Table name: job_titles
#
#  id         :integer          not null, primary key
#  account_id :integer
#  position   :integer
#  name       :string
#  abbr       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class JobTitle::AsStart < JobTitle
  include ExtendedModel

  # do not allow to duplicate titles
  validates :position, presence: true, uniqueness: { scope: :account_id }

  def self.create_initial(account_id)
    [[10, "Pracownik", ""],
     [20, "Kierownik", "Kie"],
     [30, "Dyrektor",  "Dyr"],
     [40, "Prezes",    "Prs"]].each do |r|

      create!(
        account_id: account_id,
        position: r[0],
        name: r[1],
        abbr: r[2])
    end
  end

end
