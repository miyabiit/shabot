module Concerns::LogicalDelete
  extend ActiveSupport::Concern

  included do
    scope :not_deleted, -> { where(deleted_at: nil) }
    scope :deleted, -> { where.not(deleted_at: nil) }

    validate :data_is_not_deleted, on: :update
  end

  def deleted?
    deleted_at.present?
  end

  def logical_delete
    update(deleted_at: Time.now)
  end

  def data_is_not_deleted
    errors.add :base, '削除済みのため更新できません' if !deleted_at_changed? && changed? && deleted_at.present?
  end
end
