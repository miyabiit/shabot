class MigrateCorporationCode < ActiveRecord::Migration
  def up
    %W(my_accounts payment_headers).each do |table_name|
      execute <<-SQL
        UPDATE
          #{table_name}
        SET
          corporation_code = CASE
                               WHEN org_name IS NULL THEN NULL
                               WHEN org_name = 'シャロンテック' THEN 1000
                               WHEN org_name = '聚楽荘' THEN 2000
                               WHEN org_name = 'JAM' THEN 2100
                               WHEN org_name = 'ベルク' THEN 2200
                               WHEN org_name = 'ブルームコンサルティング' THEN 2300
                               WHEN org_name = 'その他' THEN 2400
                               ELSE 9999
                             END
      SQL
    end
  end

  def down
    %W(my_accounts payment_headers).each do |table_name|
      execute <<-SQL
        UPDATE
          #{table_name}
        SET
          org_name = CASE
                       WHEN corporation_code IS NULL THEN NULL
                       WHEN corporation_code = 1000 THEN 'シャロンテック'
                       WHEN corporation_code = 2000 THEN '聚楽荘'
                       WHEN corporation_code = 2100 THEN 'JAM'
                       WHEN corporation_code = 2200 THEN 'ベルク'
                       WHEN corporation_code = 2300 THEN 'ブルームコンサルティング'
                       WHEN corporation_code = 2400 THEN 'その他'
                       ELSE NULL
                     END
      SQL
    end
  end
end
