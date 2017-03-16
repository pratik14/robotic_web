class TestCasesController < ApplicationController
  before_action :authenticate_user!, except: :create
  before_action :authenticate_token!, only: :create
  before_action :set_test_case, only: [:show, :edit, :update, :destroy]

  def index
    @test_cases = TestCase.all.paginate(:page => params[:page], :per_page => 5).order('created_at DESC')
  end

  def new
    @test_case = TestCase.new
  end

  def create
    @test_case = TestCase.new(name: params[:name])
    params['key'].each do |index, attrs|
      keyword = Keyword.where(name: attrs['trigger']).first
      test_case_params.merge!(keyword_id: keyword.id)
      @test_case.events.build(test_case_params)
    end
    @test_case.save
    head :ok
  end

  def update
    respond_to do |format|
      if @test_case.update(test_case_params)
        format.html { redirect_to @test_case, notice: 'Test case was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @test_case.destroy
    redirect_to test_cases_url, notice: 'Test case was successfully destroyed.'
  end

  def verify
    test_case = TestCase.find params[:id]
    test_case.verify
    redirect_to action: :index
  end

  def download
    test_case = TestCase.find params[:id]
    send_file File.open("#{Rails.root}/public#{test_case.source_file.url}".split('?')[0])
  end

  private

  def set_test_case
    @test_case = TestCase.find(params[:id])
  end

  def test_case_params
    params.require(:test_case).permit(:name, :status, :message, events_attributes: [:keyword_id, :locator, :value, :text, :expected, :url, :id, :_destroy])
  end

  def authenticate_token!
    begin
      @user = User.find(auth_token: params[:auth_token])
    rescue
      render json: { errors: ['Not Authenticated'] }, status: :unauthorized
    end
  end
end
