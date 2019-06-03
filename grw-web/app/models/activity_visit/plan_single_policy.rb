class ActivityVisit::PlanSinglePolicy < Policy
  delegate :user_role, :activity_on, to: :@policy_object

  def can_destroy?
    if new_record?
      errors.add(:base, "nie jest jeszcze zapisany w bazie")
      return false
    end
    if activity_on.past?
      errors.add(:activity_on, "musi być w przyszłości")
      return false
    end

    true
  end

  def can_cancel?
    if new_record?
      errors.add(:base, "nie jest jeszcze zapisany w bazie")
      return false
    end
    unless activity_on.past?
      errors.add(:activity_on, "musi być w przeszłości")
      return false
    end

    true
  end

  def can_convert_to_reported?
    if new_record?
      errors.add(:base, "nie jest jeszcze zapisany w bazie")
      return false
    end

    if activity_on.future?
      errors.add(:base, "zaraportować można tylko wizyty które się odbyły")
      return false
    end

    true
  end

end