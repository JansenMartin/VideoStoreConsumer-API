class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  def index
    if params[:query]
      data = MovieWrapper.search(params[:query])
    else
      data = Movie.all
    end

    render status: :ok, json: data
  end

  def show
    render(
      status: :ok,
      json: @movie.as_json(
        only: [:title, :overview, :release_date, :inventory],
        methods: [:available_inventory],
      ),
    )
  end

  def add_movie
    movie = Movie.new(title: params[:title], overview: params[:overview], release_date: params[:release_date], image_url: params[:image_url], external_id: params[:external_id])

    already_added = Movie.find_by(external_id: params[:external_id])

    if already_added
      render status: :conflict, json: {errors: "This movie is already in the library"}
    elsif movie.save
      render status: :ok, json: {}
    else
      render status: :bad_request, json: {errors: movie.errors.messages}
    end
  end

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: {errors: {title: ["No movie with title #{params["title"]}"]}}
    end
  end
end
