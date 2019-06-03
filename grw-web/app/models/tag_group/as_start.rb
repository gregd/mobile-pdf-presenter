# == Schema Information
#
# Table name: tag_groups
#
#  id               :integer          not null, primary key
#  account_id       :integer
#  position         :integer
#  klasses          :string           default([]), not null, is an Array
#  name             :string
#  abbr             :string
#  color            :string
#  has_hierarchy    :boolean          default(FALSE), not null
#  has_uniqueness   :boolean          default(FALSE), not null
#  has_main_tagging :boolean          default(FALSE), not null
#  is_eco_sector    :boolean          default(FALSE), not null
#  is_target        :boolean          default(FALSE), not null
#  is_important     :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#

class TagGroup::AsStart < TagGroup
  include ExtendedModel

  def self.create_initial(account_id)
    [[1, ["OrgUnit", "Person"], "Target", "target", true, true,
      [[1, "Grupa A", "A", "Najważniejsi klienci", "#ff1200"],
       [2, "Grupa B", "B", "Przyszłościowi klienci", "#ff6155"],
       [3, "Grupa C", "C", "Okazjonalni klienci", "#ffb0aa"]]],

     [2, ["Person"], "Zajęcie", "zajęcie", false, true,
      [[1, "Sprzedaż",    "sprzedaż",   "prace związane ze sprzedażą i marketingiem", "#686868"],
       [2, "Księgowość",  "księgowość", "pracuje w księgowości", "#686868"],
       [3, "Produkcja",   "produkcja",  "prace zawiązane z produkcją", "#686868"],
       [4, "Logistyka",   "logistyka",  "prace związane z logistyką ", "#686868"]]],

     [3, ["OrgUnit"], "Branża", "branża", false, true,
      [[1, "FMGC",      "FMGC",       "produkty szybkozbywalne", "#8a8100"],
       [2, "Farmacja",  "farmacja",   "apteki, hurtownie i firmy farmaceutyczne", "#8a8100"],
       [3, "Zdrowie",   "zdrowie",    "przychodnie, szpitale, gabinety", "#8a8100"],
       [4, "Spożywcza", "spożywcza",  "producenci żywności", "#8a8100"],
       [5, "Budowlana", "budowlana",  "firmy budowlane", "#8a8100"],
       [6, "Usługi",    "usługi",     "małe firmy usługowe", "#8a8100"]]],

    ].each do |g|

      group = TagGroup::AsEdit.create!(
        account_id: account_id,
        position:       g[0],
        klasses:        g[1],
        name:           g[2],
        abbr:           g[3],
        has_uniqueness: g[4],
        is_important:   g[5])

      g[6].each do |t|
        Tag::AsEdit.create!(
          account_id:   account_id,
          tag_group_id: group.id,
          position:     t[0],
          name:         t[1],
          abbr:         t[2],
          description:  t[3],
          color:        t[4])
      end
    end
  end

end
