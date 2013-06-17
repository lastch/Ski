class BuyingGuidesController < ApplicationController
  before_filter :admin_required, except: [:show]
  layout 'admin', except: [:show]

  before_filter :find_buying_guide, only: [:edit, :update, :show, :destroy]

  def index
    @buying_guides = BuyingGuide.all
  end

  def new
    @buying_guide = BuyingGuide.new
  end

  def create
    @buying_guide = BuyingGuide.new(buying_guide_params)

    if @buying_guide.save
      redirect_to(buying_guides_path, notice: t('notices.created'))
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @buying_guide.update_attributes(buying_guide_params)
      redirect_to(edit_buying_guide_path(@buying_guide), notice: t('notices.saved'))
    else
      render 'edit'
    end
  end

  def show
    @heading_a = "Buying Guide for #{@buying_guide.country}"
    default_page_title(@heading_a)
    @featured_properties = @buying_guide.country.featured_properties(5)
  end

  def destroy
    @buying_guide.destroy
    redirect_to buying_guides_path
  end

  protected

  def find_buying_guide
    @buying_guide = BuyingGuide.find_by_id(params[:id])
    if admin?
      redirect_to(buying_guides_path) unless @buying_guide
    else
      not_found if !@buying_guide
    end
  end

  def buying_guide_params
    params.require(:buying_guide).permit(:content, :country_id)
  end
end
