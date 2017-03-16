class TestCasesController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_test_case, only: [:show, :edit, :update, :destroy]

  # GET /test_cases
  # GET /test_cases.json
  def index
    @test_cases = TestCase.all.paginate(:page => params[:page], :per_page => 5).order('created_at DESC')
  end

  # GET /test_cases/1
  # GET /test_cases/1.json
  def show
  end

  # GET /test_cases/new
  def new
    @test_case = TestCase.new
  end

  # GET /test_cases/1/edit
  def edit
  end

  # POST /test_cases
  # POST /test_cases.json
  def create
    if request.xhr?
      @test_case = TestCase.new(name: params[:name])
      params['key'].each do |index, attrs|
        keyword = Keyword.where(name: attrs['trigger']).first
        @test_case.events.build({
          locator: attrs['locator'],
          value: attrs['value'],
          text: attrs['text'],
          url: attrs['url'],
          expected: attrs['expected'],
          keyword_id: keyword.id
        })
      end

      @test_case.save

      respond_to do |format|
        format.js { head :ok }
      end
    else
      @test_case = TestCase.new(test_case_params)

      if @test_case.save
        redirect_to @test_case, notice: 'Test case was successfully created.'
      else
        render :new
      end
    end
  end

  # PATCH/PUT /test_cases/1
  # PATCH/PUT /test_cases/1.json
  def update
    respond_to do |format|
      if @test_case.update(test_case_params)
        format.html { redirect_to @test_case, notice: 'Test case was successfully updated.' }
        format.json { render :show, status: :ok, location: @test_case }
      else
        format.html { render :edit }
        format.json { render json: @test_case.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /test_cases/1
  # DELETE /test_cases/1.json
  def destroy
    @test_case.destroy
    respond_to do |format|
      format.html { redirect_to test_cases_url, notice: 'Test case was successfully destroyed.' }
      format.json { head :no_content }
    end
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
    # Use callbacks to share common setup or constraints between actions.
    def set_test_case
      @test_case = TestCase.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def test_case_params
      params.require(:test_case).permit(:name, :status, :message, events_attributes: [:keyword, :locator, :value, :id, :_destroy])
    end
end
