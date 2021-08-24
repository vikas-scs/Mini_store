class Deposit < ApplicationRecord
	belongs_to :user
	belongs_to :admin
	has_many :transactions
	validates :update_count, numericality: { less_than_or_equal_to: 1,  only_integer: true }
	before_save do |deposit|
		   if deposit.update_count > 1
			   puts "here"
			   false
			   puts "You have already updated action before!"
		    else
		    	puts "coming"
		       deposit.update_count = deposit.update_count + 1
		   end
    end
    after_save do |deposit|
    	@wallet = UserWallet.find(deposit.user_id)
		   if deposit.status == "accepted"
		   	   @transaction = Transaction.new
    	       @transaction.ref_id =  "TRAN" + rand(7 ** 7).to_s
    	       @transaction.transaction_type = "credit"
    	       @transaction.user_id = deposit.user_id
    	       @transaction.admin_id = deposit.admin_id
    	       @transaction.deposit_id = deposit.id
    	       @transaction.description = "Deposit money to wallet"
		   	   @transaction.amount = deposit.amount
		   	   @wallet.balance = @wallet.balance + deposit.amount
		   	   @wallet.save
		   	   @transaction.remaining_balance = @wallet.balance
		   	   @transaction.save
		   	elsif deposit.status == "rejected"
		   	   @wallet.balance = @wallet.balance + 0
		   	   @wallet.save
		   	end  	
    end
end
