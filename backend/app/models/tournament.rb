class Tournament < ApplicationRecord
  has_many :events
  has_many :seasons
  has_many :tournament_subscriptions
  has_many :tournament_aliases

  def self.from_hash(tournament_data)
    tournament = find_by(slug: tournament_data['slug'])
    Rails.logger.info tournament.inspect

    tournament || create!(
      {
        ss_id: tournament_data['id'],
        slug: tournament_data['slug'],
        name: tournament_data['name']
      }
    )
  end

  def self.find_by_alias_name(alias_name)
    joins(:tournament_aliases).where('tournament_aliases.alias': alias_name.downcase).first
  end

  def self.search(tournament_name)
    Rails.logger.info("[Tournament] Searching for tournament #{tournament_name}.")
    Rails.logger.info('[Tournament] Trying exact match.')
    tournament = find_by_name(tournament_name)
    Rails.logger.info("[Tournament] Exact match found #{tournament.name}.") if tournament

    unless tournament
      Rails.logger.info('[Tournament] Trying alias search.')
      tournament = Tournament.find_by_alias_name tournament_name
      Rails.logger.info "[Tournament] Found tournament by alias: #{tournament.name}." if tournament
    end

    unless tournament
      Rails.logger.info '[Tournament] Trying api search'
      tournament = Api::Client.search_tournament(tournament_name)
      Rails.logger.info("[Tournament] Found tournament in api search: #{tournament.name}") if tournament
    end

    raise Errors::TournamentNotFound, "#{I18n.t :tournament_not_found}: #{tournament_name}." unless tournament

    tournament
  end
end
