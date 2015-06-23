class Admin::SettingsController < Admin::BaseController
  cache_sweeper :blog_sweeper

  def index
    this_blog.base_url = blog_base_url if this_blog.base_url.blank?
    load_settings
  end

  def write
    load_settings
  end

  def feedback
    load_settings
  end

  def display
    load_settings
  end

  def update
    load_settings
    if @setting.update_attributes(settings_params)
      flash[:success] = I18n.t('admin.settings.update.success')
      redirect_to action: action_param
    else
      flash[:error] = I18n.t('admin.settings.update.error',
                             messages: this_blog.errors.full_messages.join(', '))
      render action_param
    end
  end

  def update_database
    @current_version = migrator.current_schema_version
    @needed_migrations = migrator.pending_migrations
  end

  def migrate
    migrator.migrate
    redirect_to update_database_admin_settings_url
  end

  private

  VALID_ACTIONS = %w(index write feedback display)

  def settings_params
    @settings_params ||= params.require(:setting).permit!
  end

  def action_param
    @action_param ||=
      begin
        value = params[:from]
        VALID_ACTIONS.include?(value) ? value : 'index'
      end
  end

  def load_settings
    @setting = this_blog
  end

  def migrator
    @migrator ||= Migrator.new
  end
end
