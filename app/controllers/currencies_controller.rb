class CurrenciesController < ApplicationController
  before_filter :admin_required
  before_filter :no_browse_menu
  before_filter :find_currency, only: [:edit, :update]

  def index
    @heading_a = render_to_string(partial: 'index_heading').html_safe
    @currencies = Currency.order('code')
  end

  def new
    @heading_a = render_to_string(partial: 'create_edit_heading').html_safe
    @currency = Currency.new
  end

  def create
    @currency = Currency.new(params[:currency])

    if @currency.save
      redirect_to(currencies_path, notice: t('notices.created'))
    else
      render 'new'
    end
  end

  def edit
    @heading_a = render_to_string(partial: 'create_edit_heading').html_safe
  end

  def update
    if @currency.update_attributes(params[:currency])
      redirect_to(currencies_path, notice: t('notices.saved'))
    else
      render 'edit'
    end
  end

  def update_exchange_rates
    Currency.update_exchange_rates
    redirect_to currencies_path, notice: t('currencies_controller.exchange_rates_updated')
  end

  protected

  def find_currency
    @currency = Currency.find(params[:id])
  end
end
