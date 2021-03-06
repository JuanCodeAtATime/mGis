class Api::ProjectsController < AuthenticatedController
  before_action :require_admin

  def index
    collection = Project.find_by(id: params[:id]).as_json(include: {tasks: {only: [:text, :id]}, issues: {only: [:title, :id]}})
    render json: collection
  end
end
