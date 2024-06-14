class Season < ApplicationRecord
  belongs_to :tournament

  scope :current, -> { where('year LIKE ? OR year LIKE ?', "%#{Time.now.strftime('%y')}", "#{Time.now.strftime('%y')}%").first }

  def self.from_hash(season_data)
    tournament = season_data.delete(:tournament)
    season = tournament.seasons.find_by(year: season_data['year'])

    season || tournament.seasons.create!(
      ss_id: season_data['id'],
      year: season_data['year'],
    )
  end
end
