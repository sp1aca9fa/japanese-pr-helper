# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


puts "Cleaning DB"
User.destroy_all

puts "Clearing then seeding the application journeys..."
ApplicationJourney.destroy_all
9.times do |i|
  application_journey = ApplicationJourney.new(
    application_road: i + 1,
  )
  application_journey.system_prompt = ApplicationJourney::DESCRIPTION[application_journey.application_road.to_sym]
  application_journey.description = ApplicationJourney::DESCRIPTION[application_journey.application_road.to_sym]
  application_journey.save!
end
puts "... #{ApplicationJourney.count} application journeys added"

puts "Seeding test users"
# puts "Seeding test chats"
# puts "Seeding test messages"

9.times do |i|
  user = User.new(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    email: "email#{User.count}@domain.com",
    password: "123456"
  )
  user.save!
  # user_application = UserApplication.new(
  #   user: user,
  #   application_journey: ApplicationJourney.all[i],
  #   title: Faker::Artist.name
  # )
  # user_application.save!
  # chat = Chat.new(
  #   title: Faker::Military.navy_rank,
  #   user_application: user_application
  # )
  # chat.save!
  # 3.times do
  #   message = Message.new(
  #     chat: chat,
  #     content: Faker::Lorem.paragraph,
  #     role: ["assistant", "user"].sample
  #   )
  #   message.save!
  # end
end

puts "Finished putting #{User.count} user(s)"
# puts "Finished putting #{UserApplication.count} user application(s)"
# puts "Finished putting #{Chat.count} chat(s)"
# puts "Finished putting #{Message.count} message(s)"
