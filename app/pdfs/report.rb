module Report
  ReportList = [
    ['月別プロジェクト別出金予定・実績一覧','each-project-payment-list', '/casein/reports/pdf_each_project'],
    ['月別支払日別出金予定・実績一覧','each-day-payment-list', '/casein/reports/pdf_each_day'],
    # ['月別出金予定・実績','payment-monthly', '/casein/reports/pdf_monthly'],
    ['入出金レポート','payment-receipt', '/casein/reports/pdf_payment_receipt'],
    ['未払申請一覧','not-processed-payment', '/casein/reports/pdf_not_processed_payment'],
    ['支払処理済申請一覧','processed-payment', '/casein/reports/pdf_processed_payment'],
  ]
end
