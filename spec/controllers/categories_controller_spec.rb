require 'spec_helper'

describe CategoriesController do
  let(:website) { mock_model(Website).as_null_object }
  let(:category) { mock_model(Category).as_null_object }

  before do
    Website.stub(:first).and_return(website)
    Category.stub(:new).and_return(category)
    controller.stub(:admin?).and_return(true)
  end

  describe "GET new" do
    it "instantiates a new category" do
      Category.should_receive(:new)
      get :new
    end

    it "assigns @category" do
      get :new
      expect(assigns[:category]).to equal(category)
    end
  end

  describe "POST create" do
    let(:params) { {category: { "name" => "Restaurants" }} }

    it "instantiates a new category with the given params" do
      Category.should_receive(:new).with(params[:category])
      post :create, params
    end

    context "when the category saves successfully" do
      before do
        category.stub(:save).and_return(true)
      end

      it "sets a flash[:notice] message" do
        post :create, params
        expect(flash[:notice]).to eq("Created.")
      end

      it "redirects to the categories page" do
        post :create, params
        expect(response).to redirect_to(categories_path)
      end
    end

    context "when the category fails to save" do
      before do
        category.stub(:save).and_return(false)
      end

      it "assigns @category" do
        post :create, params
        expect(assigns[:category]).to eq(category)
      end

      it "renders the new template" do
        post :create, params
        expect(response).to render_template('new')
      end
    end
  end

  describe 'GET show' do
    let(:cat)    { FactoryGirl.create(:category) }
    let(:resort) { FactoryGirl.create(:resort) }

    context 'with results' do
      before do
        Category.unstub(:new)
        da = FactoryGirl.create(:directory_advert, category: cat, resort: resort)
        Advert.new_for(da).start_and_save!
      end

      it 'succeeds' do
        get :show, id: cat.id, resort_slug: resort.to_param
        expect(response).to be_successful
      end
    end

    context 'with no results' do
      it '404s' do
        Category.unstub(:new)
        get :show, id: cat.id, resort_slug: resort.to_param
        expect(response.status).to eq 404
      end
    end
  end

  describe 'DELETE destroy' do
    it 'finds the category' do
      Category.should_receive(:find_by).with(id: '1')
      delete 'destroy', id: 1
    end

    context 'when the category is found' do
      before { Category.stub(:find_by).and_return(category) }

      it 'destroys the category' do
        category.should_receive(:destroy)
        delete 'destroy', id: 1
      end

      it 'sets a flash[:notice] message' do
        post 'destroy', id: 1
        expect(flash[:notice]).to eq 'Deleted.'
      end

      it 'redirects to the categories page' do
        delete 'destroy', id: 1
        expect(response).to redirect_to(categories_path)
      end
    end
  end
end
