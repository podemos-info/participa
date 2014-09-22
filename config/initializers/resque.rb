# https://coderwall.com/p/o0nhuq
class CanAccessResque
  def matches?(request)
    user = request.env['warden'].user
    return false if user.blank?
    Ability.new(user).can? :manage, Resque
  end
end
