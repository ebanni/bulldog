class VatRatePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.visible_to(user)
    end
  end

  def permitted_attributes
    # if user.admin? || user.owner_of?(vat_rate)
      [:account_id, :name, :rate, :active]
    # end
  end

  def index?
    user.account.business?
  end

  def create?
    user.account.business?
  end

  def update?
    user.account.business?
  end

  def destroy?
    user.account.business?
  end

end