# coding: utf-8

# 入出金レポートの集計処理を行うクラス
class PaymentReceiptSummary
  # 集計レコードクラス
  class Record
    attr_accessor :date_range, :receipt, :payment, :balance, :flow, :children
    def initialize(date_range, receipt, payment, balance, flow, children={})
      @date_range = date_range
      @receipt = receipt
      @payment = payment
      @balance = balance
      @flow = flow
      @children = children
    end

    def date_range_label
      "#{@date_range.begin.strftime('%d日')} 〜 #{@date_range.end.strftime('%d日')}"
    end
  end

  attr_accessor :data

  attr_reader :from, :to

  def initialize(from, to)
    @from = from
    @to = to

    @receipts = ReceiptHeader.receipt_on_is_not_null
    @payments = PaymentHeader.payable_on_is_not_null
    @projects = Hash[Project.all.map{|p| [p.id, p]}]

    from_min = [@receipts.minimum(:receipt_on), @payments.minimum(:payable_on)].compact.min.try(:beginning_of_month).try(:to_date)
    to_max = [@receipts.maximum(:receipt_on), @payments.maximum(:payable_on)].compact.max.try(:end_of_month).try(:to_date)

    return if !from_min || !to_max # zero records

    @from = from_min if from < from_min
    @to   = to_max if to > to_max
  end

  def project_label(project_id)
    if project = @projects[project_id]
      project.name_and_category
    end
  end

  def summaries_by_year
    return [] if @to < @from
    inital_flow = cashflow_to(@from, @receipts, @payments)
    summaries_by_10days = summarize_by_10days(@from, @to, @receipts, @payments, inital_flow)
    summaries_by_month = summarize_by_month(summaries_by_10days, inital_flow)
    summarize_by_year(summaries_by_month, inital_flow)
  end

  def summaries_project_by_year(project_id)
    receipts = @receipts.where(project_id: project_id)
    payments = @payments.where(project_id: project_id)
    inital_flow = cashflow_to(@from, receipts, payments)
    summarize_by_year(summaries_project_by_month(project_id, inital_flow), inital_flow)
  end

  def summaries_project_by_month(project_id, inital_flow = nil)
    return [] if @to < @from
    receipts = @receipts.where(project_id: project_id)
    payments = @payments.where(project_id: project_id)
    unless inital_flow
      inital_flow = cashflow_to(@from, receipts, payments)
    end
    summaries_by_10days = summarize_by_10days(@from, @to, receipts, payments, inital_flow, true)
    summarize_by_month(summaries_by_10days, inital_flow)
  end

  # 10日単位の集計から月単位の集計を行う
  def summarize_by_month(summaries_by_10days, inital_flow)
    flow = inital_flow
    summaries_by_10days.group_by {|s| s.date_range.begin.beginning_of_month.to_date }.map {|date, summaries|
      balance = summaries.map(&:balance).compact.inject(0, :+)
      flow += balance
      Record.new(((summaries.map{|s| s.date_range.begin}.min)..(summaries.map{|s| s.date_range.end}.max)),
                summaries.map(&:receipt).compact.inject(0, :+),
                summaries.map(&:payment).compact.inject(0, :+),
                balance,
                flow,
                summaries.inject({}){|h, s| h[[(s.date_range.begin.day - 1) / 10, 2].min] = s; h }
                )
    }
  end

  # 月単位の集計から年単位の集計を行う
  def summarize_by_year(summaries_by_month, inital_flow)
    flow = inital_flow
    summaries_by_month.group_by {|s| s.date_range.begin.beginning_of_year.to_date }.map {|date, summaries|
      balance = summaries.map(&:balance).compact.inject(0, :+)
      flow += balance
      Record.new(((summaries.map{|s| s.date_range.begin}.min)..(summaries.map{|s| s.date_range.end}.max)),
                summaries.map(&:receipt).compact.inject(0, :+),
                summaries.map(&:payment).compact.inject(0, :+),
                balance,
                flow,
                summaries.inject({}){|h, s| h[s.date_range.begin.beginning_of_month.to_date] = s; h }
                )
    }
  end

  # 10日単位で集計を行う
  def summarize_by_10days(from, to, receipts, payments, inital_flow, skip_project_record=false)
    summaries = []
    target_month = from.prev_month.to_date
    prev_record = nil
    break_by_10days(from, to).each do |date_range|
      if target_month != date_range.begin.beginning_of_month.to_date
        target_month = date_range.begin.beginning_of_month.to_date
      end
      receipt_query = receipts.where(receipt_on: date_range)
      payment_query = payments.joins(:payment_parts).where(payable_on: date_range)
      receipt_amount = receipt_query.sum(:amount)
      payment_amount = payment_query.sum('payment_parts.amount')
      balance = receipt_amount - payment_amount
      flow = (prev_record.try(:flow) || inital_flow) + balance

      project_records = {}
      unless skip_project_record
        receipt_query.group(:project_id).sum(:amount).each do |k, v|
          next if k.nil?
          project_records[k] = Record.new(date_range, v, 0, v, v)
        end
        payment_query.group(:project_id).sum('payment_parts.amount').each do |k, v|
          next if k.nil?
          record = (project_records[k] ||= Record.new(date_range, 0, v, -v, -v))
          record.payment = v
          record.balance = record.receipt - record.payment
          record.flow = (prev_record.try(:children).try(:[], k).try(:flow) || 0) + record.balance
        end
      end
      if receipt_amount > 0 || payment_amount > 0
        record = Record.new(date_range, receipt_amount, payment_amount, balance, flow, Hash[project_records.sort])
        summaries << record
        prev_record = record
      end
    end
    summaries
  end

  # 10日単位で日付を分解し、日付範囲の配列を返す
  def break_by_10days(from, to)
    from = from.to_date
    to = to.to_date
    target_month = from.beginning_of_month.to_date
    terms = [(from..to)]
    while target_month <= to.beginning_of_month
      [0, 10, 20].each do |break_day_num|
        break_day = target_month.since((break_day_num-1).days).to_date
        if terms.last.include?(break_day) && break_day != terms.last.end
          last = terms.pop
          terms << (last.begin .. break_day)
          terms << ((break_day.since(1.day).to_date) .. (last.end.to_date))
        end
      end
      target_month = target_month.next_month
    end
    terms
  end

  def cashflow_to(date, receipts, payments)
    receipt_query = receipts.where('receipt_headers.receipt_on < ?', date)
    payment_query = payments.joins(:payment_parts).where('payment_headers.payable_on < ?', date)
    receipt_amount = (receipt_query.sum(:amount) || 0)
    payment_amount = (payment_query.sum('payment_parts.amount') || 0)
    receipt_amount - payment_amount
  end
end
