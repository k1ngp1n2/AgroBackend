class Member::TransactionsController < ApplicationController
  before_action :authenticate_user
  before_action :set_transaction, only: [:show, :update, :destroy]
  include Exceptable

  # GET /transactions
  # GET /transactions.json
  def index
    @transactions = Transaction.all
  end

  # GET /transactions/1
  # GET /transactions/1.json
  def show
    build do
      message 'Транзакция детально'
      view 'member/transactions/show'
    end
  end

  # POST /transactions
  # POST /transactions.json
  def create
    build do
      if params[:transaction][:type] == 'withdrawal' && current_user.amount < params[:transaction][:amount]
          @need_money = params[:transaction][:amount] - current_user.amount
          @after = current_user.amount - params[:transaction][:amount]
          @amount = params[:transaction][:amount]
          message 'На счёте недостаточно средств'
          view 'member/transactions/withdrawal'    
      else
          type = params[:transaction][:type]
          amount = params[:transaction][:amount]
          if type == 'replenish'
            @transaction = Transaction.transaction_replenish current_user, amount
            message 'Пополнение счета'
          elsif type == 'withdrawal' && current_user.user_type == 'admin'
            @transaction = Transaction.transaction_withdrawal Administrator.second, amount
            message 'Снятие со счета'
          elsif type == 'withdrawal' 
            @transaction = Transaction.transaction_withdrawal current_user, amount
            message 'Снятие со счета'
          end
          view 'member/transactions/show'
      end
    end
  end

  # PATCH/PUT /transactions/1
  # PATCH/PUT /transactions/1.json
  # def update
  #  if @transaction.update(transaction_params)
  #    render :show, status: :ok, location: @transaction
  #  else
  #    render json: @transaction.errors, status: :unprocessable_entity
  #  end
  # end

  # DELETE /transactions/1
  # DELETE /transactions/1.json
  def destroy
    @transaction.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transaction_params
      params.require(:transaction).permit(:from_id, :to_id, :amount, :ask_id, :order_id, :status)
      #params.require(:transaction).permit(:ask_id, :status)
    end
end
