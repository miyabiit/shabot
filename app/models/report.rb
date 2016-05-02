class Report < ActiveRecord::Base
	ReportList = [
		['月別プロジェクト別出金予定・実績一覧','payment-list', '/casein/reports/pdf_list'],
		['月別支払日別出金予定・実績一覧','payment-list2', '/casein/reports/pdf_list2'],
		# ['月別出金予定・実績','payment-monthly', '/casein/reports/pdf_monthly'],
		['入出金レポート','payment-receipt', '/casein/reports/pdf_payment_receipt'],
	]

end
