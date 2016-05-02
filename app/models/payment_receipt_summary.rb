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

  attr_reader :from, :to, :summaries_by_year

  def initialize(from, to)
    @from = from
    @to = to
    @summaries_by_year = []
    @projects = {}
  end

  # 指定された日付範囲で集計を実行する
  def fetch
    return if to < from

    receipts = ReceiptHeader.where('receipt_headers.receipt_on IS NOT NULL')
    payments = PaymentHeader.where('payment_headers.payable_on IS NOT NULL')

    from_min = [receipts.minimum(:receipt_on), payments.minimum(:payable_on)].compact.min.try(:beginning_of_month).try(:to_date)
    to_max = [receipts.maximum(:receipt_on), payments.maximum(:payable_on)].compact.max.try(:end_of_month).try(:to_date)

    return if !from_min || !to_max # zero records

    @from = from_min if from < from_min
    @to   = to_max if to > to_max

    summaries_by_10days = summarize_by_10days(from, to, receipts, payments)
    summaries_by_month = summarize_by_month(summaries_by_10days)
    @summaries_by_year = summarize_by_year(summaries_by_month)
    @projects = Hash[Project.all.map{|p| [p.id, p]}]
  end

  def get_all_project_report(pdf)
    Report::AllProjectReport.new(self, pdf)
  end

  def project_label(project_id)
    if project = @projects[project_id]
      project.name_and_category
    end
  end

  # 10日単位の集計から月単位の集計を行う
  def summarize_by_month(summaries_by_10days)
    flow = 0
    summaries_by_10days.group_by {|s| s.date_range.begin.beginning_of_month.to_date }.map {|date, summaries|
      if date.month == 1
        flow = 0
      end
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
  def summarize_by_year(summaries_by_month)
    flow = 0
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
  def summarize_by_10days(from, to, receipts, payments)
    summaries = []
    target_month = from.prev_month.to_date
    prev_record = nil
    break_by_10days(from, to).each do |date_range|
      if target_month != date_range.begin.beginning_of_month.to_date
        target_month = date_range.begin.beginning_of_month.to_date
        prev_record = nil
      end
      receipt_query = receipts.where(receipt_on: date_range)
      payment_query = payments.joins(:payment_parts).where(payable_on: date_range)
      receipt_amount = receipt_query.sum(:amount)
      payment_amount = payment_query.sum('payment_parts.amount')
      balance = receipt_amount - payment_amount
      flow = (prev_record.try(:flow) || 0) + balance

      project_records = {}
      receipt_query.group(:project_id).sum(:amount).each do |k, v|
        project_records[k] = Record.new(date_range, v, 0, v, v)
      end
      payment_query.group(:project_id).sum('payment_parts.amount').each do |k, v|
        record = (project_records[k] ||= Record.new(date_range, 0, v, -v, -v))
        record.payment = v
        record.balance = record.receipt - record.payment
        record.flow = (prev_record.try(:children).try(:[], k).try(:flow) || 0) + record.balance
      end
      if receipt_amount > 0 || payment_amount > 0
        record = Record.new(date_range, receipt_amount, payment_amount, balance, flow, Hash[project_records.sort])
        summaries << record
      end
      prev_record = record
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
        if terms.last.include?(break_day) && break_day != terms.last.end && break_day != terms.last.begin
          last = terms.pop
          terms << (last.begin .. break_day)
          terms << ((break_day.since(1.day).to_date) .. (last.end.to_date))
        end
      end
      target_month = target_month.next_month
    end
    terms
  end
end
