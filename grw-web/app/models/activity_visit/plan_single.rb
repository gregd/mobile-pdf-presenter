class ActivityVisit::PlanSingle < ActiveType::Object
  include AccountScoped
  include WithPolicy

  attribute :id,              :integer
  attribute :account_id,      :integer
  attribute :creator_role_id, :integer
  attribute :user_role_id,    :integer
  attribute :org_unit_id,     :integer
  attribute :address_id,      :integer
  attribute :person_id,       :integer
  attribute :activity_on,     :date
  attribute :comments,        :string

  belongs_to :user_role
  belongs_to :org_unit
  belongs_to :address
  belongs_to :person

  normalize_attributes :comments

  validates :creator_role_id, presence: true
  validates :user_role_id, presence: true
  validates :org_unit_id, presence: true
  validates :address_id, presence: true
  validates :activity_on, presence: true
  validate :validate_dates, :validate_person

  before_validation :set_defaults
  before_save :sync_changes

  def set_defaults
  end

  def validate_dates
    if activity_on&.past?
      errors.add(:activity_on, "Data planowanej wizyty nie może być w przeszłości")
    end
  end

  def validate_person
    scope = ActivityVisit.active.where(activity_on: activity_on, has_time: false, user_role_id: user_role_id)
    scope = scope.where("activity_visits.id != ?", id) unless new_record?

    if person_id
      existing_count = scope.joins(:activity_participants).where("activity_participants.person_id = ?", person_id).count
      if existing_count > 0
        errors.add(:person_id, "z tą osobą jest już zaplanowana wizyta")
      end

    else
      existing_count = scope.where(org_unit_id: org_unit_id, active_participants_count: 0).count
      if existing_count > 0
        errors.add(:person_id, "w tej instytucji jest już zaplanowana wizyta")
      end
    end
  end

  def populate(v)
    @new_record = false
    @cache_visit = v
    self.id              = v.id
    self.account_id      = v.account_id
    self.activity_on     = v.activity_on
    self.creator_role_id = v.creator_role_id
    self.user_role_id    = v.user_role_id
    self.org_unit_id     = v.org_unit_id
    self.address_id      = v.address_id
    self.comments        = v.comments
    if v.active_participants_count > 0
      self.person_id = v.activity_participants.to_a.first.person_id
    end
    self
  end

  def sync_changes
    if new_record?
      create_records
    else
      update_records
    end
  end

  def create_records
    ActivityVisit.transaction do
      v = ActivityVisit::AsEdit.new

      v.klass           = ActivityVisit::KLASS_SINGLE
      v.validity_state  = ActivityVisit::STATE_VALID
      v.activity_stage  = ActivityVisit::STAGE_PLANNED
      v.planned_at      = Time.now
      v.activity_on     = activity_on
      v.creator_role_id = creator_role_id
      v.user_role_id    = user_role_id
      v.org_unit_id     = org_unit_id
      v.address_id      = address_id
      v.comments        = comments
      v.user_updated_at = Time.now
      if person_id
        v.active_participants_count = 1
      else
        v.active_participants_count = 0
      end
      v.save!

      if person_id
        ActivityParticipant.create!(
          activity:       v,
          activity_uuid:  v.uuid,
          person_id:      person_id,
          person_uuid:    person.uuid)
      end

      # @new_record = false
      self.id = v.id
      @cache_visit = v
    end
  end

  def update_records
    ActivityVisit.transaction do
      v = load_visit(id)

      v.validity_state  = ActivityVisit::STATE_VALID
      v.planned_at      = Time.now
      v.activity_on     = activity_on
      v.creator_role_id = creator_role_id
      v.user_role_id    = user_role_id
      v.org_unit_id     = org_unit_id
      v.address_id      = address_id
      v.comments        = comments
      v.user_updated_at = Time.now
      if person_id
        v.active_participants_count = 1
      else
        v.active_participants_count = 0
      end
      v.save!

      if person_id
        p = v.activity_participants.first
        p.person_id    = person_id
        p.person_uuid  = person.uuid
        p.save!
      else
        if p = v.activity_participants.first
          p.deleted_at = Time.now
          p.save!
        end
      end
    end
  end

  def destroy!
    ActivityVisit.transaction do
      v = load_visit(id)

      v.activity_participants.each do |p|
        p.deleted_at = Time.now
        p.save!
      end

      v.user_updated_at = Time.now
      v.deleted_at = Time.now
      v.save!
    end
  end

  def convert_to_reported!
    ActivityVisit.transaction do
      v = load_visit(id)

      v.validity_state  = ActivityVisit::STATE_DRAFT
      v.activity_stage  = ActivityVisit::STAGE_REPORTED
      v.reported_at     = Time.now
      v.user_updated_at = Time.now
      v.save!
    end
  end

  def self.find(id)
    v = ActivityVisit.find(id)
    check_state(v)
    new.populate(v)
  end

  private

  def load_visit(id)
    @cache_visit ||= begin
      v = ActivityVisit::AsEdit.find(id)
      self.class.check_state(v)
      v
    end
  end

  def self.check_state(v)
    raise "wrong klass" if v.klass != ActivityVisit::KLASS_SINGLE
    raise "wrong stage" unless v.stage_planned?
  end

end

