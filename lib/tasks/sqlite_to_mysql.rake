namespace :sqlite_to_mysql do
  TABLES = %W(
    accounts
    casein_admin_users
    items
    number_masters
    payment_headers
    payment_parts
    projects
    reports
  )

  desc "create dump dir"
  task :create_dump_dir do
    dump_path = Rails.root.join('db', 'dump')
    unless File.exists?(dump_path)
      Dir.mkdir(dump_path)
    end
  end

  desc "export csv"
  task :export_csv => :create_dump_dir do
    db_file = ENV['DB_FILE'] || "db/#{Rails.env}.sqlite3"
    TABLES.each do |table_name|
      puts "export db/dump/#{table_name}.csv ..."
      puts `sqlite3 -csv -header #{db_file} "SELECT * FROM #{table_name}" > #{Rails.root.join('db', 'dump', "#{table_name}.csv")}`
    end
  end

  desc "import csv"
  task :import_csv do
    app_name = Rails.application.class.parent.to_s.underscore
    host = ENV['HOST'] || 'localhost'
    user = ENV['USER'] || 'root'
    password  = ENV['PASSWORD'] || ''
    TABLES.each do |table_name|
      sql = <<-SQL
        LOAD DATA LOCAL INFILE "#{Rails.root.join('db', 'dump', "#{table_name}.csv")}" REPLACE INTO TABLE #{table_name} FIELDS TERMINATED BY ',' ENCLOSED BY '"' IGNORE 1 LINES
      SQL
      sql.gsub!(/"/, '\\"')
      puts "import #{table_name}.csv ..."
      puts `mysql --local-infile=1 -h #{host} -u#{user} -p#{password} #{app_name}_#{Rails.env} -e "#{sql}"`
    end
  end
end
