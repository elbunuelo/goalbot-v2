class AliasManager
  def self.create_alias(team_name, wanted_alias)
    team = Team.search(team_name)

    return I18n.t(:team_not_found) unless team

    team_alias = TeamAlias.find_by_alias wanted_alias.downcase
    return I18n.t(:alias_already_exists, alias: team_alias.alias, team: team_alias.team.name) if team_alias

    team_alias = team.team_aliases.build({ alias: wanted_alias })

    return "#{I18n.t(:created_alias)} #{team_alias.team.name} -> #{team_alias.alias}" if team_alias.save

    team_alias.errors
  end
end
