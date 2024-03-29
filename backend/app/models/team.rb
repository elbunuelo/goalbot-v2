class Team < ApplicationRecord
  has_many :home_events, class_name: 'Event', foreign_key: :home_team_id
  has_many :away_events, class_name: 'Event', foreign_key: :away_team_id
  has_many :team_aliases
  has_many :team_subscriptions

  scope :playing_today, lambda {
                          joins('LEFT JOIN events ON (events.home_team_id = teams.id OR events.away_team_id = teams.id)').where('events.date = ?', Date.today)
                        }

  def matching_score(search)
    slug.pair_distance_similar search.downcase
  end

  def self.from_hash(team_data)
    team = find_by(slug: team_data['slug'])

    team || create!(
      {
        ss_id: team_data['id'],
        slug: team_data['slug'],
        name: team_data['name'],
        short_name: team_data['shortName']
      }
    )
  end

  def self.find_by_alias_name(alias_name)
    joins(:team_aliases).where('team_aliases.alias': alias_name.downcase).first
  end

  def self.search(team_name)
    Rails.logger.info("[Team] Searching for team #{team_name}.")
    Rails.logger.info('[Team] Trying exact match.')
    team = find_by_name(team_name)
    Rails.logger.info("[Team] Exact match found #{team.name}.") if team

    unless team
      Rails.logger.info('[Team] Trying short name match')
      team = find_by_short_name team_name
      Rails.logger.info "[Team] Found team by short name: #{team.name}." if team
    end

    unless team
      Rails.logger.info('[Team] Trying alias search.')
      team = Team.find_by_alias_name team_name
      Rails.logger.info "[Team] Found team by alias: #{team.name}." if team
    end

    unless team
      Rails.logger.info('[Team] Trying search cache match')
      team = SearchCache.find_by_search(team_name)&.team
      Rails.logger.info "[Team] Found team in cache search: #{team.name}." if team
    end

    unless team
      Rails.logger.info '[Team] Trying api search'
      team = Api::Client.search_team(team_name)
      Rails.logger.info("[Team] Found team in api search: #{team.name}") if team
    end

    raise Errors::TeamNotFound, "#{I18n.t :team_not_found}: #{team_name}." unless team

    team
  end
end
