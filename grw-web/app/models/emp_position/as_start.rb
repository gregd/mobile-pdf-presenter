# == Schema Information
#
# Table name: emp_positions
#
#  id             :integer          not null, primary key
#  account_id     :integer
#  parent_id      :integer
#  path           :ltree
#  name           :string
#  user_role_id   :integer
#  node_order     :integer
#  node_name      :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deleted_at     :datetime
#  max_depth      :integer
#  children_count :integer
#

class EmpPosition::AsStart < EmpPosition
  include ExtendedModel

  EMP_TWO   = 1
  EMP_THREE = 2

  def self.for_first_user(account_id)
    where(account_id: account_id, parent_id: nil).first
  end

  def self.templates
    [["2 poziomy", EMP_TWO],
     ["3 poziomy", EMP_THREE]].freeze
  end

  def self.create_initial(account_id, template_id)
    case template_id
      when EMP_TWO   then create_initial_2_level(account_id)
      when EMP_THREE then create_initial_3_level(account_id)
      else raise "Unknown template #{template}"
    end
  end

  private

  def self.create_initial_2_level(account_id)
    director = new
    director.account_id = account_id
    director.name = "Polska"
    director.max_depth = 2
    director.save!

    ["pomorskie", "zachodnie", "mazurskie", "wschodnie", "mazowieckie", "wielkopolskie", "śląskie", "małopolskie"].each do |name|
      ter = new
      ter.account_id = account_id
      ter.parent = director
      ter.name = name
      ter.save!
    end
  end

  def self.create_initial_3_level(account_id)
    director = new
    director.account_id = account_id
    director.name = "Polska"
    director.max_depth = 3
    director.save!

    reg1 = new
    reg1.account_id = account_id
    reg1.parent = director
    reg1.name = "Pn-Wsch"
    reg1.save!

    reg2 = new
    reg2.account_id = account_id
    reg2.parent = director
    reg2.name = "Pn-Zach"
    reg2.save!

    reg3 = new
    reg3.account_id = account_id
    reg3.parent = director
    reg3.name = "Pd-Zach"
    reg3.save!

    reg4 = new
    reg4.account_id = account_id
    reg4.parent = director
    reg4.name = "Pd-Wsch"
    reg4.save!

    [[reg1, ["mazowieckie", "podlaskie", "warmińsko-mazurskie", "lubelskie"]],
     [reg2, ["pomorskie", "zachodniopomorskie", "kujawsko-pomorskie", "lubuskie"]],
     [reg3, ["wielkopolskie", "dolnośląskie", "opolskie", "łódzkie"]],
     [reg4, ["śląskie", "małopolskie", "świętokrzyskie", "podkarpackie"]]].each do |r|
      reg = r[0]
      r[1].each do |name|
        ter = new
        ter.account_id = account_id
        ter.parent = reg
        ter.name = name
        ter.save!
      end
    end
  end

end
