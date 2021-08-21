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
            puts "why"
	  		    flash[:notice] = "You can't deposit money this time.Your previous deposit under process"
                redirect_to wallets_path
            return	
	    end  
    end
    def create
    	@wallet = current_user.user_wallet
    	amount = params["balance"].to_f
      if amount < 0                                             #the adding money should be greater then 0 
          flash[:notice] = "invalid amount"
          redirect_to wallets_path
          return
      end
      @deposit = Deposit.new                                    #generating the request for adding the money to user wallet
      @deposit.ref_id = "dep" + rand(7 ** 7).to_s
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
end
