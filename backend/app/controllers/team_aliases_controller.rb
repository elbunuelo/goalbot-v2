class TeamAliasesController < ApplicationController
  skip_before_action :verify_authenticity_token

  rescue_from Errors::TeamNotFound, with: :team_not_found

  # POST /team_aliases or /team_aliases.json
  def create
    all_params = team_alias_params
    team_name = all_params.delete(:team_name)

    team = Team.search(team_name)
    raise Errors::TeamNotFound, I18n.t(:team_not_found) unless team

    @team_alias = TeamAlias.find_by_alias all_params[:alias]
    record_exists = @team_alias.present?

    message = AliasManager.create_alias team_name, all_params[:team_alias]

    respond_to do |format|
      if @team_alias.save
        format.json do
          if record_exists
            render json: { message: message}, status: :ok
          else
            render json: { message: message }, status: :created
          end
        end
      else
        format.json { render json: @team_alias.errors, status: :unprocessable_entity }
      end
    end
  end

  # Only allow a list of trusted parameters through.
  def team_alias_params
    params.require(:team_alias).permit(:team_name, :alias)
  end

  private

  def team_not_found
    render json: { message: error.to_s }, status: 400
  end
end
