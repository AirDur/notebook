# Controller for top-level pages of the site that do not have
# an associated model
class MainController < ApplicationController
  layout 'landing', only: [:index, :about_notebook, :for_writers, :for_roleplayers, :for_designers, :for_friends]

  before_action do
    if !user_signed_in? && params[:referral]
      session[:referral] = params[:referral]
    end
  end

  def index
    redirect_to :dashboard if user_signed_in?
  end

  def about_notebook
  end

  def comingsoon
  end

  def dashboard
    return redirect_to new_user_session_path unless user_signed_in?

    # if user_signed_in? && current_user.universes.count > 1 && @universe_scope.nil?
    #   redirect_to universes_path
    #   return
    # end

    @content_types = (
      Rails.application.config.content_types[:all].map(&:name) & # Use config to dictate order
      current_user.user_content_type_activators.pluck(:content_type)
    )

    ask_question
  end

  def prompts
    return redirect_to new_user_session_path unless user_signed_in?

    ask_question
  end

  def notes
    return redirect_to new_user_session_path unless user_signed_in?
  end

  def recent_content
    content_types = Rails.application.config.content_types[:all]

    @recent_edits = content_types.flat_map { |klass|
      klass.where(user_id: current_user.id)
           .order(updated_at: :desc)
           .limit(100)
    }.sort_by(&:updated_at)
    .last(100)
    .reverse

    @recent_creates = content_types.flat_map { |klass|
      klass.where(user_id: current_user.id)
           .order(created_at: :desc)
           .limit(100)
    }.sort_by(&:created_at)
    .last(100)
    .reverse
  end

  def for_writers
  end

  def for_roleplayers
  end

  def for_designers
  end

  def for_friends
    @subscriber_count = User.where(selected_billing_plan_id: [3, 4]).count
    @drawing_date = 'June 15, 2017 12:00pm'.to_date

    @subscriber_count = 20 # manual override to match graphics

    session["user_return_to"] = request.original_url unless user_signed_in?
  end
  helper_method :resource_name, :resource, :devise_mapping

  def feature_voting
  end

  private

  class RetryMe < StandardError; end
  def ask_question
    if @universe_scope.present? && attempts < 2
      content_pool = current_user.content_in_universe(@universe_scope).values.flatten
    else
      content_pool = current_user.content.values.flatten
    end

    @content = content_pool.sample
  end


  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

end
