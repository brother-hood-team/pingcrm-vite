class UsersController < ApplicationController
  def index
    render inertia: 'Users/Index', props: {
      users: -> {
        jbuilder do |json|
          json.array! users do |user|
            json.(user, :id, :email, :name, :owner, :deleted_at)
            json.can do
              json.edit_user can?(:edit, user)
            end
          end
        end
      },
      can: {
        create_user: can?(:create, User)
      },
      filters: {}
    }
  end

  def new
    unless can?(:create, User)
      redirect_to users_path, alert: 'You are not allowed to do this!'
      return
    end

    render inertia: 'Users/New'
  end

  def edit
    render inertia: 'Users/Edit', props: {
      user: -> {
        jbuilder do |json|
          json.(user, :id, :email, :first_name, :last_name, :owner, :deleted_at)
          json.photo user.photo.attached? ? polymorphic_url(user.photo.variant(resize_to_fill: [64, 64])) : nil
        end
      },
      can: {
        edit_user: can?(:edit, user)
      }
    }
  end

  def create
    unless can?(:create, User)
      redirect_to users_path, alert: 'You are not allowed to do this!'
      return
    end

    new_user = current_user.account.users.new(user_params)

    if new_user.save
      redirect_to users_path, notice: 'User created.'
    else
      session[:errors] = new_user.errors
      redirect_to new_user_path
    end
  end

  def update
    unless can?(:edit, user)
      redirect_to edit_user_path(user), alert: 'You are not allowed to do this!'
      return
    end

    if user.update(user_params)
      redirect_to [ :edit, user ], notice: 'User updated.'
    else
      session[:errors] = user.errors
      redirect_to edit_user_path(user)
    end
  end

  def destroy
    unless can?(:destroy, user)
      redirect_to edit_user_path(user), alert: 'You are not allowed to do this!'
      return
    end

    user.soft_delete!
    redirect_to edit_user_path(user), notice: 'User deleted.'
  end

  def restore
    user.restore!
    redirect_to edit_user_path(user), notice: 'User restored.'
  end

  private

  def user
    @user ||= current_user.account.users.find(params[:id])
  end

  def users
    @users ||= current_user.
               users.
               search(params[:search]).
               trash_filter(params[:trashed]).
               role_filter(params[:role]).
               order_by_name
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :owner,
      :password,
      :photo
    ).tap do |p|
      p.delete(:photo) if p[:photo].blank?
    end
  end
end