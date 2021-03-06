class Transaction < ApplicationRecord
  belongs_to :account, class_name: 'User', foreign_key: 'account_id'
  belongs_to :from, class_name: 'User', foreign_key: 'from_id'
  belongs_to :to, class_name: 'User', foreign_key: 'to_id'
  belongs_to :ask, optional: true
  belongs_to :order, optional: true
  belongs_to :task, optional: true

  # Резервирование средств
  def self.transaction_reserve(user, ask)
    transactions = []
    system = Administrator.first

    hash = {
      account: user,
      t_type: 'reserve',
      direction: 'outflow',
      amount: ask.total,
      from: user,
      to: system,
      before: user.amount,
      after: user.amount - ask.total,
      ask: ask
    }
    outflow = Transaction.create!(hash)
    account_withdrawal(user, ask.total) if outflow

    hash = {
      account: system,
      t_type: 'reserve',
      direction: 'inflow',
      amount: ask.total,
      from: user,
      to: system,
      before: system.amount,
      after: system.amount + ask.total,
      ask: ask
    }
    inflow = Transaction.create!(hash)
    account_replenish(system, ask.total) if inflow

    transactions.push outflow, inflow
    transactions
  end

  # Пополнение и снятие
  def self.transaction_replenish(user, amount)
    member_transaction 'replenish', user, amount
  end

  def self.transaction_withdrawal(user, amount)
    member_transaction 'withdrawal', user, amount
  end

  def self.member_transaction(type, user, amount)
    hash = {
      account: user,
      t_type: type,
      direction: type == 'replenish' ? 'inflow' : 'outflow',
      amount: amount,
      from: user,
      to: user,
      before: user.amount,
      after: type == 'replenish' ? user.amount + amount : user.amount - amount}
    transaction = Transaction.create!(hash)
    if transaction
      account_replenish(user, amount) if type == 'replenish'
      account_withdrawal(user, amount) if type == 'withdrawal'
    end
    transaction
  end

  def self.account_replenish(user, amount)
    user.amount += amount
    user.save
  end

  def self.account_withdrawal(user, amount)
    user.amount -= amount
    user.save
  end

  def self.system_payments(ask)
    # перевести деньги со счета системы на счета каждого продавца
    # перевести деньги со счера системы на счет транспортной компании
    # перевести деньги со счета системы в прибыль системы

    total = ask.total
    delivery = ask.delivery_cost
    to_producers = ((total - delivery) * 0.9).to_i
    profit = total - delivery - to_producers
    puts "total #{total} delivery #{delivery} to_producers #{to_producers} profit #{profit}"

    system = Administrator.first
    syster_profit = Administrator.second
    carrier = Carrier.first
    task = Task.find_by(ask: ask)

    # Зачисление перевозчику
    hash = {
        account: system,
        t_type: 'transfer',
        direction: 'outflow',
        amount: delivery,
        from: system,
        to: carrier,
        before: system.amount,
        after: system.amount - delivery,
        ask: ask,
        task: task
    }
    outflow = Transaction.create!(hash)
    account_withdrawal(system, delivery) if outflow

    hash = {
        account: carrier,
        t_type: 'transfer',
        direction: 'inflow',
        amount: delivery,
        from: system,
        to: carrier,
        before: carrier.amount,
        after: carrier.amount + delivery,
        ask: ask,
        task: task
    }
    inflow = Transaction.create!(hash)
    account_replenish(carrier, delivery) if inflow

    puts "total #{total} delivery #{delivery} to_producers #{to_producers} profit #{profit}"

    ask.orders.each do |order|

      producer = order.producer
      amount = (order.total * 0.9).to_i
      delta = order.total - amount

      # Зачисление производителю
      hash = {
          account: system,
          t_type: 'transfer',
          direction: 'outflow',
          amount: amount,
          from: system,
          to: producer,
          before: system.amount,
          after: system.amount - amount,
          ask: ask,
          order: order
      }
      outflow = Transaction.create!(hash)
      account_withdrawal(system, amount) if outflow

      hash = {
          account: producer,
          t_type: 'transfer',
          direction: 'inflow',
          amount: amount,
          from: system,
          to: producer,
          before: producer.amount,
          after: producer.amount + amount,
          ask: ask,
          order: order
      }
      inflow = Transaction.create!(hash)
      account_replenish(producer, amount) if inflow

      # Зачисление прибыли
      hash = {
          account: system,
          t_type: 'profit',
          direction: 'outflow',
          amount: delta,
          from: system,
          to: syster_profit,
          before: system.amount,
          after: system.amount - delta,
          ask: ask
      }
      outflow = Transaction.create!(hash)
      account_withdrawal(system, delta) if outflow

      hash = {
          account: syster_profit,
          t_type: 'profit',
          direction: 'inflow',
          amount: delta,
          from: system,
          to: syster_profit,
          before: syster_profit.amount,
          after: syster_profit.amount + delta,
          ask: ask
      }
      inflow = Transaction.create!(hash)
      account_replenish(syster_profit, delta) if inflow
    end

    # ask.update status: 'Выполнен'
    # p ask
  end
end
