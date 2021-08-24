class OrderController < ApplicationController
    def my_deposits
        @deposits = current_user.deposits
    end
	def address                       
		@address = current_user.addresses              #getting the cuurent user address that addeda before 
		if params[:final].present?
            @total = params[:final].to_f
        else
            @total = params[:total].to_f
        end
	end
	def order_detail
        @ops = OrdersProduct.where(user_id: current_user.id)
		@order = Order.find(params[:order_id])        #getting the required order details and its transactions
		@transactions = @order.transactions.where(user_id:current_user.id)
        @coupon = @order.coupon
        @address = @order.address
        
	end
	def select_address
		if params[:select_address].present?               #continuing the previous address as current order address
			@address = Address.find(params[:id])
			@total = params[:total]
	    else                                            #adding new address to user address
            if params[:d_no].empty? || params[:street].empty? || params[:village].empty? || params[:state].empty? || params[:pincode].empty?      #displaying message if any field is empty
                 flash[:notice] = "fields can't be empty"
                 redirect_to address_path(total: params[:total])
                 return
            end
	    	@address = Address.new
	    	@address.user_id = current_user.id
            @address.d_no = params[:d_no]
			@address.street = params[:street]
			@address.village = params[:village]
			@address.state = params[:state]
			@address.pincode = params[:pincode]
			@total = params[:total]
			@address.save
		end
		if @total.to_f > current_user.user_wallet.balance                     #checking whether the user balance is more than require order place money
			@due = @total.to_f - current_user.user_wallet.balance
			flash[:notice] = "Insufficient Balance..please add #{@due} to continue"
			redirect_to new_wallet_path(id: current_user.id, due: @due)
			return
		end
	end
    def apply_coupon
        if params[:change_coupon].present?
            @cu = CouponsUser.where(user_id: current_user.id, coupon_id: params[:coupon_id]).first
            @cu.destroy
        end
        @coupons = Coupon.all
        @address = Address.find(params[:address_id])
        @total = params[:total]
    end
	def place_order
        puts params.inspect
        if params[:coupon_id].present?                #checking whether the coupon is applied for order
        	@final_amount1 = params[:amount].to_f - params[:total].to_f
            @benifit = params[:total].to_f
            @final_amount = params[:amount].to_f
            @coupon = Coupon.find(params[:coupon_id])
            @address = Address.find(params[:address_id])
        else
        	@benifit = 0
        	@final_amount = params[:total].to_f
            @address = Address.find(params[:address_id])
        end
	end
	def confirm
		if params[:c_id].present?                   #checking whether the coupon is applied for order
        	@final_amount = params[:total].to_f
            @coupon = Coupon.find(params[:c_id])
            if @coupon.percentage.present? && @coupon.amount.present?
                @save = (@final_amount * @coupon.percentage) / 100
                if @save > @final_amount
                    @benifit = @final_amount
                else
                    @benifit = @save
                end
            elsif !@coupon.amount.present?
                puts @final_amount
                puts @coupon.percentage
                @offer = (@final_amount * @coupon.percentage) / 100
                puts @offer
                @benifit = @offer
            elsif !@coupon.percentage.present?
               if @coupon.amount >= @final_amount
                   @benifit = @final_amount
                else
                    @benifit = @coupon.amount
                end
            end
        else
        	@benifit = 0
        	@final_amount = params[:total].to_f
        end
		@admin_wallet = Admin.first.admin_wallet    #adding the money to admin wallet for selling the products
        @order = Order.new                          #creating the order
        @order.ref_id ="ORD" + rand(7 ** 7).to_s
        @order.final_amount = @final_amount - @benifit
        @order.coupon_benifit = @benifit
        @order.status = "processing"
        @order.address_id = params[:address_id]
        @order.delivery_date = Date.today + 7
        @order.user_id = current_user.id
        if params[:c_id].present?           
            @order.coupon_id = params[:c_id].to_i
        end
        if @order.save
            @cart = current_user.cart
            @cart.products.each do |c|                            #decrement the product avilable count in peoduct table
        	    @product = Product.find(c.id)
        	    @product.available_count = @product.available_count - @product.cart_count
        	    @product.cart_count = 1
        	    @product.save
                @cp = CartsProduct.where(user_id: current_user.id, product_id: @product.id, cart_id: current_user.cart.id).first
        	    @op = OrdersProduct.new
        	    @op.product_id = c.id
        	    @op.order_id = @order.id
                @op.quantity = @cp.quantity
                @op.user_id = current_user.id
                @op.order_id =@order.id
                @op.save!
            end
            @user_wallet = current_user.user_wallet           #debiting the money from user to place the order
		    UserWallet.transaction do
                @user_wallet.with_lock do                     #locking the user wallet 
                    @user_wallet.balance = @user_wallet.balance - params[:total].to_f
                    if @user_wallet.save!
                        @transaction = Transaction.new              #creating a new transaction
                        @transaction.user_id = current_user.id
                        @transaction.transaction_type = "debit"
                        @transaction.description = "Buying products"
                        @transaction.ref_id = "TRAN" + rand(7 ** 7).to_s
                        @transaction.amount = params[:total].to_f
                        @transaction.remaining_balance = @user_wallet.balance
                        @transaction.order_id = @order.id
                        @transaction.save
                    end
                end
            end
            @admin_wallet = Admin.first.admin_wallet
            AdminWallet.transaction do
        	    @admin_wallet.with_lock do
        	        @admin_wallet.balance = @admin_wallet.balance + params[:total].to_f
        	        if @admin_wallet.save!
                        @transaction1 = Transaction.new                    #creating the transaction for user debit
                        @transaction1.admin_id = 1
                        @transaction1.transaction_type = "credit"
                        @transaction1.description = "selling products"
                        @transaction1.ref_id = "TRAN" + rand(7 ** 7).to_s
        	            @transaction1.amount = params[:total].to_f
        	            @transaction1.remaining_balance = @admin_wallet.balance
        	            @transaction1.order_id = @order.id
                        @transaction1.save
                    end
                end
            end
            if @cart.products.destroy_all                        #remoing the items from the cart after adding to order table
        	    flash[:alert] = "Order palced Successfully!!!!"
			    redirect_to order_path
			     return
		    end
        end
	end
	def coupon
		@address = current_user.addresses.first
		@total = params[:total].to_f
        @address_id = params[:address_id]                           #appying to the order
		@cupon = Coupon.where('lower(coupon_name) = ?', params[:c_name].downcase).first               #checking whwther the coupon is valid or invalid
		if @cupon.present?                                                          #contiune if the coupon is exist
			@cuponusers = CouponsUser.where(user_id: current_user.id, coupon_id: @cupon.id)
            if @cuponusers.length < @cupon.usage_count                              #checking the coupon usage of user
                if @cupon.expiry_date > Date.today
                    if @cupon.percentage.present? && @cupon.amount.present?                      #checking whether amount and percentage are available in table
                        @offer = (@total * @cupon.percentage) / 100
                        if @offer > @cupon.amount
                            @offer = @cupon.amount
                        end
                        @cu = CouponsUser.new
                        @cu.user_id = current_user.id
                        @cu.coupon_id = @cupon.id
                        if @cu.save
                           flash[:alert] = "Coupon Applied Successfully!!!"
			               redirect_to place_order_path(coupon_id: @cupon.id,total: @offer, amount: @total,address_id: @address_id)
			               return
			            end
			        elsif !@cupon.amount.present?                                      #checking whether amount and percentage are available in table                 
                        @offer = (@total * @cupon.percentage) / 100
                        @cu = CouponsUser.new
                        @cu.user_id = current_user.id
                        @cu.coupon_id = @cupon.id
			        	if @cu.save
                           flash[:alert] = "Coupon Applied Successfully!!!"
			               redirect_to place_order_path(coupon_id: @cupon.id,total: @offer,amount: @total,address_id: @address_id)
			               return
			            end
			        elsif !@cupon.percentage.present?                                         #checking whether amount and percentage are available in table
			        	if @cupon.amount >= @total
                            @offer = @total
                            @cu = CouponsUser.new
                            @cu.user_id = current_user.id
                            @cu.coupon_id = @cupon.id
			         	    if @cu.save
                                flash[:alert] = "Coupon Applied Successfully!!!"
			                    redirect_to place_order_path(coupon_id: @cupon.id,total: @offer,amount: @total,address_id: @address_id)
			                    return
			                end
			            else
			            	@offer = @cupon.amount
                            @cu = CouponsUser.new
                            @cu.user_id = current_user.id
                            @cu.coupon_id = @cupon.id
                            if @cu.save
                                flash[:alert] = "Coupon Applied Successfully!!!"
			                    redirect_to place_order_path(coupon_id: @cupon.id,total: @offer,amount: @total,address_id: @address_id )
			                    return
			                end
			            end
			        end
                else
                	flash[:notice] = "coupon is already expired..please try another coupon!!!"
			        redirect_to apply_coupon_path(total: @total,address_id: @address_id)
			        return
			    end
            else
            	flash[:notice] = "maximum usage for coupon to user is over please try another coupon!!!"
			    redirect_to apply_coupon_path(total: @total,address_id: @address_id)
			    return
			end
		else
			flash[:notice] = "Coupon not found!!!"
			redirect_to apply_coupon_path(total: @total,address_id: @address_id)
			return
		end
	end
    def remove_coupon
        @coupon = Coupon.find(params[:c_id])
        @cu = CouponsUser.where(user_id: current_user.id, coupon_id: @coupon.id).first
        @total = params[:total]
        @address = Address.find(params[:address_id])
        if @cu.destroy
            flash[:alert] = "Coupon removed Successfully!!!"
            redirect_to place_order_path(total: @total, address_id: @address.id)
            return
       end 
    end
    def cancel_order
        @ops = OrdersProduct.where(user_id: current_user.id)
        @order = Order.find(params[:order_id])
        if @order.status == "cancelled"
            flash[:notice] = "Already cancelled!!!"
            redirect_to order_path
            return
        end
        @coupon = @order.coupon
        @order.status = "cancelled"
        if @order.save
            if @coupon.present?
                @cp = CouponsUser.where(user_id: current_user.id, coupon_id: @coupon.id).first
                @cp.destroy
            end
            @products = @order.products
            @products.each do |product|
                @ops.each do |op|
                    if op.product_id == product.id && op.order_id == @order.id
                        product.available_count = product.available_count + op.quantity
                        product.save
                    end
                end
            end
            @user_wallet = current_user.user_wallet           #debiting the money from user to place the order
            UserWallet.transaction do
                @user_wallet.with_lock do                     #locking the user wallet 
                    @user_wallet.balance = @user_wallet.balance + @order.final_amount
                    if @user_wallet.save!
                        @transaction = Transaction.new              #creating a new transaction
                        @transaction.user_id = current_user.id
                        @transaction.transaction_type = "credit"
                        @transaction.description = "refund for cancelled Product"
                        @transaction.ref_id = "TRAN" + rand(7 ** 7).to_s
                        @transaction.amount = @order.final_amount
                        @transaction.remaining_balance = @user_wallet.balance
                        @transaction.order_id = @order.id
                        if @transaction.save
                           flash[:alert] = "Order Cancelled Successfully!!!"
                           redirect_to order_path
                           return
                        end  
                    end
                end
            end 
        end  
    end
end
