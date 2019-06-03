# == Schema Information
#
# Table name: foreign_api_calls
#
#  id           :integer          not null, primary key
#  category     :string
#  is_blocked   :boolean          default(FALSE), not null
#  on_day       :date
#  counter      :integer          default(0), not null
#  last_call_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  lock_version :integer          default(0), not null
#

class ForeignApiCall < ApplicationRecord
  CATEGORIES = %w(google_geocode google_directions nominatim geoportal).freeze
  PAUSE = 1

  validates :category, :presence => true, :inclusion => { :in => CATEGORIES }
  validates :on_day, :presence => true
  validates :counter, :presence => true

  def self.left_per_day(category, day_limit)
    return 0 if locked?(category)
    day_limit - day_counter_for(category)
  end

  def self.next_call(category)
    return false if locked?(category)
    limit_rate(category)
    increment_for(category)
    true
  end

  @@last_api_call = {}
  def self.limit_rate(category)
    t = @@last_api_call[category]
    sleep PAUSE if t && (Time.now - t < PAUSE)
    @@last_api_call[category] = Time.now
  end

  def self.lock_calls!(category)
    FileUtils.touch(lock_path(category))
    #AdminMailer.query_limit_email(category).deliver_now
  end

  def self.locked?(category)
    File.exists?(lock_path(category))
  end

  def self.day_counter_for(category)
    where(:category => category, :on_day => pst_today).first.counter
  end

  def self.increment_for(category)
    raise "Invalid category" unless CATEGORIES.include?(category)
    # Google probably counts limits in their timezone
    exec_sql "UPDATE foreign_api_calls
            SET counter = counter + 1
            WHERE category = ? AND on_day = ?",
             category, pst_today
  end

  def self.add_counters
    # Just in case create record for yesterday because of time zones and three days in future
    (-1 .. 3).each do |i|
      d = Date.today + i
      CATEGORIES.each do |cat|
        next if where("category = ? AND on_day = ?", cat, d).count > 0
        res = create(:category => cat, :on_day => d, :counter => 0)
        unless res
          puts "Warning: Cannot create api call counter for #{cat} and #{d}"
        end
      end
    end
  end

  def self.clear_counters
    where(:on_day => pst_today).update_all(counter: 0)
  end

  def self.pst_today
    Time.now.in_time_zone("Pacific Time (US & Canada)").to_date
  end

  def self.lock_path(category)
    File.join(Rails.root, 'tmp', "lock_#{category}")
  end

end
