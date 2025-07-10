task fetch_goal_video_links: :environment do
  def match_goal(title)
    GoalMatcher.check title
  rescue Errors::NoGoalMatch
    Rails.logger.info "[GoalVideoLinks] Submission \"#{title}\" does not appear to be a goal."
    nil
  end

  Reddit.process_submissions do |submission|
    next unless submission.link_flair_text == 'Media'

    Rails.logger.info "[GoalVideoLinks] Processing submission -- #{submission.title}"
    goal = match_goal submission.title
    next unless goal

    begin
      home_team = Team.search goal[:home_team]
      away_team = Team.search goal[:away_team]
      home_team_event = Event.find_team_event_today home_team
      away_team_event = Event.find_team_event_today away_team
      next unless home_team_event
      next unless away_team_event
      next unless home_team_event == away_team_event
    rescue Errors::TeamNotFound
      next
    rescue Errors::EventNotFound
      next
    end

    incident = home_team_event.incidents.find_pending_link_by_score(goal[:home_score], goal[:away_score])
    next unless incident

    Rails.logger.info "[GoalVideoLinks] Goal video found for #{incident.event.home_team.name} #{incident.home_score} - #{incident.away_score} #{incident.event.away_team.name} --  #{submission.url}"
    incident.video_url = submission.url
    incident.save
  end
end
