class OrderController < ApplicationController
	def address
		puts params.inspect
		@address = current_user.addresses.first
		@total = params[:total]
	end
	def order_detail
		@order = Order.find(params[:order_id])
		@transactions = @order.transactions
		puts @transactions
	end
	def select_address
		puts params.inspect
		if params[:same_address].present?
			puts "allow here"
			@address = current_user.addresses.first
			@total = params[:total]
	    else
            if params[:d_no] == "" || params[:street] == "" || params[:village] = "" || params[:state] = "" || params[:pincode] = ""
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
		if @total.to_f > current_user.user_wallet.balance
			@due = @total.to_f - current_user.user_wallet.balance
			flash[:notice] = "Insufficient Balance..please add #{@due} to continue"
			redirect_to new_wallet_path(id: current_user.id, due: @due)
			return
		end
		@coupons = Coupon.all
	end
	def place_order
        puts params.inspect
        if params[:coupon_id].present?
        	@coupon = Coupon.find(params[:coupon_id])
        	@coupon.usage_count = @coupon.usage_count - 1
        	@coupon.save
        	@final_amount = params[:amount].to_f - params[:total].to_f
        	@benifit = params[:total].to_f
        else
        	@benifit = 0
        	@final_amount = params[:total]
        end
	end
	def confirm
		if params[:c_id].present?
        	@final_amount = params[:total].to_f
        	@benifit = params[:benifit].to_f
        else
        	@benifit = 0
        	@final_amount = params[:total].to_f
        end
		puts params.inspect
		@admin_wallet = Admin.first.admin_wallet
		@transaction = Transaction.new
		@transaction.user_id = current_user.id
		@transaction.transaction_type = "debit"
		@transaction.description = "Buying products"
        @transaction.ref_id = "Trans" + rand(7 ** 7).to_s
        @order = Order.new
        @order.ref_id ="Ord" + rand(7 ** 7).to_s
        @order.final_amount = @final_amount
        @order.coupon_benifit = @benifit
        @order.delivery_date = Date.today + 7
        @order.user_id = current_user.id
        if params[:c_id].present?
            @order.coupon_id = params[:c_id].to_i
        end
        @cart = current_user.carts
        @cart.each do |c|
        	@product = Product.find(c.product_id)
        	@product.available_count = @product.available_count - @product.cart_count
        	@product.cart_count = 1
        	@product.save
        end
        @order.save
        @cart.each do |c|
        	puts "coming here"
        	@op = OrdersProduct.new
        	@op.product_id = c.product_id
        	@op.order_id = @order.id
            @op.save!
        end
        @user_wallet = current_user.user_wallet
		UserWallet.transaction do
            @user_wallet.with_lock do
                @user_wallet.balance = @user_wallet.balance - params[:total].to_f
                @user_wallet.save!
                @transaction.amount = params[:total].to_f
                @transaction.remaining_balance = @user_wallet.balance
                @transaction.order_id = @order.id
                @transaction.save
            end
        end
        @transaction1 = Transaction.new
		@transaction1.user_id = current_user.id
		@transaction1.admin_id = 1
		@transaction1.transaction_type = "credit"
		@transaction1.description = "selling products"
        @transaction1.ref_id = "Trans" + rand(7 ** 7).to_s
        @admin_wallet = Admin.first.admin_wallet
        AdminWallet.transaction do
        	@admin_wallet.with_lock do
        	    @admin_wallet.balance = @admin_wallet.balance + params[:total].to_f
        	    @admin_wallet.save!
        	    @transaction1.amount = params[:total].to_f
        	    @transaction1.remaining_balance = @admin_wallet.balance
        	    @transaction1.order_id = @order.id
                @transaction1.save
            end
        end
        if @cart.destroy_all
        	flash[:notice] = "Order palced Successfully!!!!"
			redirect_to order_path
			return
		end
	end
	def coupon
		@address = current_user.addresses.first
		@total = params[:total].to_f
		@cupon = Coupon.where('lower(coupon_name) = ?', params[:c_name].downcase).first
		if @cupon.present?
			@cuponusers = CouponsUser.where(user_id: current_user.id, coupon_id: @cupon.id)
            if @cuponusers.length < @cupon.usage_count
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
                           flash[:notice] = "Coupon Applied Successfully!!!"
			               redirect_to place_order_path(coupon_id: @cupon.id,total: @offer, amount: @total)
			               return
			            end
			        elsif !@cupon.amount.present?
                        @offer = (@total * @cupon.percentage) / 100
                        @cu = CouponsUser.new
                        @cu.user_id = current_user.id
                        @cu.coupon_id = @cupon.id
			        	if @cu.save
                           flash[:notice] = "Coupon Applied Successfully!!!"
			               redirect_to place_order_path(coupon_id: @cupon.id,total: @offer,amount: @total)
			               return
			            end
			        elsif !@cupon.percentage.present?
			        	if @cupon.amount >= @total
                            @offer = @total
                            @cu = CouponsUser.new
                            @cu.user_id = current_user.id
                            @cu.cupon_id = @cupon.id
			         	    if @cu.save
                                flash[:notice] = "Coupon Applied Successfully!!!"
			                    redirect_to place_order_path(coupon_id: @cupon.id,total: @offer,amount: @total)
			                    return
			                end
			            else
			            	@offer = @cupon.amount
                            @cu = CouponsUser.new
                            @cu.user_id = current_user.id
                            @cu.coupon_id = @cupon.id
                            if @cu.save
                                flash[:notice] = "Coupon Applied Successfully!!!"
			                    redirect_to place_order_path(coupon_id: @cupon.id,total: @offer,amount: @total)
			                    return
			                end
			            end
			        end
                else
                	flash[:notice] = "coupon is already expired..please try another coupon!!!"
			        redirect_to select_address_path(total: @total)
			        return
			    end
            else
            	flash[:notice] = "maximum usage for coupon to user is over please try another coupon!!!"
			    redirect_to select_address_path(total: @total)
			    return
			end
		else
			flash[:notice] = "Coupon not found!!!"
			redirect_to select_address_path(total: @total)
			return
		end
	end
end
