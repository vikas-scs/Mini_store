class WalletController < ApplicationController
	def index
        @wallet = current_user.user_wallet
	end
	def new
      @wallet = current_user.user_wallet
      if params[:due].present?               #checking whether request coming to login page
        	@due = params[:due]
      end
	    @success = Deposit.where(user_id: current_user.id, status: "processing")
	    if !@success.empty?
	  		  flash[:notice] = "You can't deposit money this time.Your previous deposit under process"
          redirect_to wallets_path
          return	
	    end  
  end
  def create
      @success = Deposit.where(user_id: current_user.id, status: "processing")
      if !@success.empty?
          flash[:notice] = "You can't deposit money this time.Your previous deposit under process"
          redirect_to wallets_path
          return  
      end  
    	@wallet = current_user.user_wallet
    	amount = params["balance"].to_f
      if amount < 0                                             #the adding money should be greater then 0 
          flash[:notice] = "invalid amount"
          redirect_to wallets_path
          return
      end
      @deposit = Deposit.new                                    #generating the request for adding the money to user wallet
      @deposit.ref_id = "DEP" + rand(7 ** 7).to_s
      @deposit.user_id = current_user.id
      @deposit.admin_id = 1
      @deposit.status = "processing"
      @deposit.update_count = 0
      @deposit.amount = amount
      if @deposit.save
      	  flash[:alert] = "deposite under process"
      	  redirect_to wallets_path
      end
  end

  def transactions
       @transactions = current_user.transactions
  end

  def address_edit
       @addresses = current_user.addresses
  end
  def change_address
      if params[:yes].present?
          if params[:d_no].empty? || params[:street].empty? || params[:village].empty? || params[:state].empty? || params[:pincode].empty?      #displaying message if any field is empty
              flash[:notice] = "fields can't be empty"
              redirect_to new_address_path
              return
          end
          @address = Address.new
          @address.user_id = current_user.id
          @address.d_no = params[:d_no]
          @address.street = params[:street]
          @address.village = params[:village]
          @address.state = params[:state]
          @address.pincode = params[:pincode]
          if @address.save
              flash[:alert] = "Address added successfully"
              redirect_to address_edit_path
              return
          end
      else
          if params[:d_no].empty? || params[:street].empty? || params[:village].empty? || params[:state].empty? || params[:pincode].empty?      #displaying message if any field is empty
              flash[:notice] = "fields can't be empty"
              redirect_to edit_address_path(id: params[:id])
              return
          end
          @address = Address.find(params[:id])
          @address.d_no = params[:d_no]
          @address.street = params[:street]
          @address.village = params[:village]
          @address.state = params[:state]
          @address.pincode = params[:pincode]
          if @address.save
              flash[:alert] = "Address changed successfully"
              redirect_to address_edit_path
              return
          end
      end
  end
end
