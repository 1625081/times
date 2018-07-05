class RoomsController < ApplicationController
  before_action :set_room, only: [:show, :edit, :update, :destroy]

  # GET /rooms
  # GET /rooms.json
  def index

  end

  def import
    Room.import(params[:file])
    redirect_to root_url, notice: "Room Data Imported"
  end
  # GET /rooms/1
  # GET /rooms/1.json
  def show
  end

  # GET /rooms/new
  def new
    @room = Room.new
  end

  # GET /rooms/1/edit
  def edit
  end

  # POST /rooms
  # POST /rooms.json
  def create
    @room = Room.new(room_params)

    respond_to do |format|
      if @room.save
        format.html { redirect_to @room, notice: 'Room was successfully created.' }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :new }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  def search
    #Room.check()
    if params[:key]
      mode,key=Room.keycheck(params[:key])
      if !key.nil?
        key.upcase!
      end
        @searchrooms,@descriptions=Room.search(mode,key)
        respond_to do |f|
          f.js
        end
      end
    end

  def more
    if params[:des] and params[:srooms]
      @searchrooms=[]
      #这里是为了让房间和房间描述保持一致
      if params[:des].split(" ").size >= 10
        @descriptions=params[:des].split(" ").drop(10)
        @searchs=params[:srooms].split(" ").drop(10)
        @searchs.each do |r|
          @searchrooms<<Room.find(r)
        end
      else
        @descriptions=[]
        @searchrooms=[]
      end

      respond_to do |f|
        f.js
      end

    end
  end

  def info
    dic={1=>"mon",2=>"tue",3=>"wed",4=>"thr",5=>"fri"}
    @column=[]#按列进行计数
    if !params[:week]
      @room=Room.find_by_class_id(params[:cid])
      @first_week=9
      @week=Time.new.strftime('%U').to_i-@first_week
      for i in 1..5
        day=eval('@room.'+dic[i])
        day||=""
        day.split(',').each do |d|
          str=""
          d.each_byte do |a|
             str<<a
           end
           @column<<str
        end
      end
    elsif params[:cid] and params[:week]
      @room=Room.find_by_class_id(params[:cid])
      @week=Integer(params[:week])
      for i in 1..5
        day=eval('@room.'+dic[i])
        day||=""
        day.split(',').each do |d|
          str=""
          d.each_byte do |a|
             str<<a
           end
           @column<<str
        end
      end
    else
      redirect_to root_url
    end
  end

  # PATCH/PUT /rooms/1
  # PATCH/PUT /rooms/1.json
  def update
    respond_to do |format|
      if @room.update(room_params)
        format.html { redirect_to @room, notice: 'Room was successfully updated.' }
        format.json { render :show, status: :ok, location: @room }
      else
        format.html { render :edit }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    @room.destroy
    respond_to do |format|
      format.html { redirect_to rooms_url, notice: 'Room was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = Room.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def room_params
      params.require(:room).permit(:class_id, :mon, :tue, :wed, :thr, :fri)
    end
end
