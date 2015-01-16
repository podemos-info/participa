class ParticipationTeamsController < InheritedResources::Base

	def join
		team = ParticipationTeam.find(params[:team_id])
		if team and not current_user.participation_team.member? team
			current_user.participation_team << team
			current_user.save
		end
		redirect_to participation_teams_path
	end

	def leave
		team = ParticipationTeam.find(params[:team_id])
		if team and current_user.participation_team.member? team
			current_user.participation_team.delete(team)
			current_user.save
		end
		redirect_to participation_teams_path
	end

end
