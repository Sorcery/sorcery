require 'oauth'

class SorceryController < ApplicationController
  protect_from_forgery

  before_action :require_login_from_http_basic, only: [:test_http_basic_auth]
  before_action :require_login, only: %i[
    test_logout
    test_logout_with_forget_me
    test_logout_with_force_forget_me
    test_should_be_logged_in
    some_action
  ]

  def index; end

  def some_action
    head :ok
  end

  def some_action_making_a_non_persisted_change_to_the_user
    current_user.email = 'to_be_ignored'
    head :ok
  end

  def test_login
    @user = login(params[:email], params[:password])
    head :ok
  end

  def test_auto_login
    @user = User.first
    auto_login(@user)
    @result = current_user
    head :ok
  end

  def test_return_to
    @user = login(params[:email], params[:password])
    redirect_back_or_to(:index, notice: 'haha!')
  end

  def test_logout
    logout
    head :ok
  end

  def test_logout_with_remember
    remember_me!
    logout
    head :ok
  end

  def test_logout_with_forget_me
    remember_me!
    forget_me!
    logout
    head :ok
  end

  def test_logout_with_force_forget_me
    remember_me!
    force_forget_me!
    logout
    head :ok
  end

  def test_invalidate_active_session
    invalidate_active_sessions!
    head :ok
  end

  def test_login_with_remember
    @user = login(params[:email], params[:password])
    remember_me!

    head :ok
  end

  def test_login_with_remember_in_login
    @user = login(params[:email], params[:password], params[:remember])

    head :ok
  end

  def test_login_from_cookie
    @user = current_user
    head :ok
  end

  def test_not_authenticated_action
    head :ok
  end

  def test_should_be_logged_in
    head :ok
  end

  def test_http_basic_auth
    head :ok
  end

  def login_at_test_twitter
    login_at(:twitter)
  end

  alias login_at_test login_at_test_twitter

  def login_at_test_facebook
    login_at(:facebook)
  end

  def login_at_test_github
    login_at(:github)
  end

  def login_at_test_paypal
    login_at(:paypal)
  end

  def login_at_test_wechat
    login_at(:wechat)
  end

  def login_at_test_microsoft
    login_at(:microsoft)
  end

  def login_at_test_google
    login_at(:google)
  end

  def login_at_test_liveid
    login_at(:liveid)
  end

  def login_at_test_jira
    login_at(:jira)
  end

  def login_at_test_vk
    login_at(:vk)
  end

  def login_at_test_salesforce
    login_at(:salesforce)
  end

  def login_at_test_slack
    login_at(:slack)
  end

  def login_at_test_line
    login_at(:line)
  end

  def login_at_test_with_state
    login_at(:facebook, state: 'bla')
  end

  def login_at_test_instagram
    login_at(:instagram)
  end

  def login_at_test_auth0
    login_at(:auth0)
  end

  def login_at_test_discord
    login_at(:discord)
  end

  def login_at_test_battlenet
    login_at(:battlenet)
  end

  def test_login_from_twitter
    if (@user = login_from(:twitter))
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  alias test_login_from test_login_from_twitter

  def test_login_from_facebook
    if (@user = login_from(:facebook))
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_github
    if (@user = login_from(:github))
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_paypal
    if (@user = login_from(:paypal))
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_wechat
    if (@user = login_from(:wechat))
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_microsoft
    if (@user = login_from(:microsoft))
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_google
    if (@user = login_from(:google))
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_liveid
    if (@user = login_from(:liveid))
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_vk
    if (@user = login_from(:vk))
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_jira
    if (@user = login_from(:jira))
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_salesforce
    if (@user = login_from(:salesforce))
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_slack
    if (@user = login_from(:slack))
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_instagram
    if (@user = login_from(:instagram))
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_auth0
    if (@user = login_from(:auth0))
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_line
    if @user = login_from(:line)
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_discord
    if (@user = login_from(:discord))
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_battlenet
    if (@user = login_from(:battlenet))
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_twitter
    if (@user = login_from(:twitter))
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_jira
    if (@user = login_from(:jira))
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  alias test_return_to_with_external test_return_to_with_external_twitter

  def test_return_to_with_external_facebook
    if (@user = login_from(:facebook))
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_github
    if (@user = login_from(:github))
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_paypal
    if (@user = login_from(:paypal))
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_wechat
    if (@user = login_from(:wechat))
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_microsoft
    if (@user = login_from(:microsoft))
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_google
    if (@user = login_from(:google))
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_liveid
    if (@user = login_from(:liveid))
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_vk
    if (@user = login_from(:vk))
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_salesforce
    if (@user = login_from(:salesforce))
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_slack
    if (@user = login_from(:slack))
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_instagram
    if (@user = login_from(:instagram))
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_auth0
    if (@user = login_from(:auth0))
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_line
    if @user = login_from(:line)
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_discord
    if (@user = login_from(:discord))
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_battlenet
    if (@user = login_from(:battlenet))
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_create_from_provider
    provider = params[:provider]
    login_from(provider)
    if (@user = create_from(provider))
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_add_second_provider
    provider = params[:provider]

    return unless logged_in?

    if (@user = add_provider_to_user(provider))
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_create_from_provider_with_block
    provider = params[:provider]
    login_from(provider)
    @user = create_from(provider) do |_user|
      # check uniqueness of email
      # User.where(email: user.email).empty?
      false
    end
    if @user
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end
end
