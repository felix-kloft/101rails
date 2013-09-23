class ClonesController < ApplicationController

  respond_to :json, :html

  def show_create
  end

  def create
    puts params
    exists = Clone.where(title: params[:title]).exists?
    if !exists
      params[:clone][:status] = 'new'
      Clone.create(params[:clone])
      render :json => {:success => true}
    else
      render :json => {:success => false, :message => "Clone already exists, choose another name."}, :status => 409
    end

  end

  def show
  end

  def index
    @clones = Clone.all
    respond_with @clones
  end

  def get
    @clone = Clone.where(title: params[:title]).first
    @clone.update_status() unless @clone.nil?
    respond_with @clone
  end

end
