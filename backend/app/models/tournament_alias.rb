class TournamentAlias < ApplicationRecord
  belongs_to :tournament
  before_create :downcase_alias

  private

  def downcase_alias
    self.alias&.downcase!
  end
end
