require 'rails_helper'

describe ImagesController do
  let(:website) { double(Website).as_null_object }

  before do
    allow(Website).to receive(:first).and_return(website)
  end

  describe 'GET index' do
    it 'assigns all images belonging to the current user to @images' do
      user = double(User, images: :images)
      allow(controller).to receive(:current_user).and_return(user)
      get 'index'
      expect(assigns(:images)).to eq :images
    end
  end

  describe 'POST create' do
    context 'when image saves' do
      before do
        allow_any_instance_of(Image).to receive(:save).and_return(true)
        allow(controller).to receive(:object).and_return(FactoryGirl.create(:property))
      end

      context 'when image height or width > 800' do
        let(:mock_image) { double(Image, id: 1).as_null_object }

        before do
          allow(Image).to receive(:new).and_return(mock_image)
          allow(mock_image).to receive(:height).and_return(1024)
          allow(mock_image).to receive(:width).and_return(768)
        end

        it 'sizes the original image' do
          expect(mock_image).to receive(:size_original!).with(800, :longest_side)
          post :create, image: { source_url: '#' }
        end
      end
    end
  end

  describe 'DELETE destroy' do
    let(:image) { double(Image).as_null_object }

    it 'finds the image' do
      expect(Image).to receive(:find).with('1').and_return(image)
      delete 'destroy', id: '1'
    end

    context 'when image is found' do
      before do
        allow(Image).to receive(:find).and_return(image)
      end

      it 'redirects to the referrer' do
        allow(request).to receive(:referer).and_return('http://example.org')
        delete 'destroy', id: '1'
        expect(response).to redirect_to('http://example.org')
      end
    end
  end
end
