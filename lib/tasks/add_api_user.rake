namespace :db do
  desc "add api user"
  task add_api_user: :environment do
    token = SecureRandom.hex
    password = SecureRandom.hex
    Casein::AdminUser.create!(
      login: 'api_user',
      name: 'api_user',
      email: 'api_user@example.com',
      access_level: 0,
      password: password,
      password_confirmation: password,
      api_token: token 
    )
    puts "Success!"
    puts "API TOKEN =="
    puts token
    puts "=="
  end
end
