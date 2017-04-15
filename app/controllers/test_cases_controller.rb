class TestCasesController < ApplicationController
  before_action :authenticate_user!, except: :create
  before_action :authenticate_token!, only: :create
  before_action :set_test_case, only: [:show, :edit, :update, :destroy]

  def index
    @test_cases = current_user.test_cases.paginate(:page => params[:page], :per_page => 5).order('created_at DESC')
  end

  def new
    @test_case = TestCase.new
  end

  ##Will receive only json request
  def create
    status, message = AddTestCase.new(params).create
    render json: { message: message }, status: status
  end

  def edit
    @keyword_list = Keyword.all.inject({}){|h,k| h[k.id]=k.required_args;h; }
  end

  def update
    respond_to do |format|
      if @test_case.update(test_case_params)
        format.html { redirect_to @test_case, notice: 'Test case was successfully updated.' }
      else
        @keyword_list = Keyword.all.inject({}){|h,k| h[k.id]=k.required_args;h; }
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
    @test_case = current_user.test_cases.find(params[:id])
  end

  def test_case_params
    params.require(:test_case).permit(:name,
                                      :status,
                                      :message,
                                      events_attributes: [:keyword_id, :locator, :value, :text, :expected,
                                                          :url, :condition, :order_number, :id, :_destroy])
  end

  def authenticate_token!
    @user = User.where(auth_token: params[:auth_token]).first
    unless @user
      render json: { errors: ['No User found with given auth token'] }, status: :unauthorized
    end
  end
end
