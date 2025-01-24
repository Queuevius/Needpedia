namespace :ai_tokens do
  desc "Reset tokens_count for all AiToken records"
  task reset_tokens_count: :environment do
    # Fetch default token counts from environment variables
    user_tokens_count = ENV['USER_TOKENS_COUNT']&.to_i
    guest_tokens_count = ENV['GUEST_TOKENS_COUNT']&.to_i

    if user_tokens_count.nil? || guest_tokens_count.nil?
      puts "Error: Please set USER_TOKENS_COUNT and GUEST_TOKENS_COUNT environment variables."
      exit(1)
    end

    puts "Resetting tokens_count for all AiToken records..."
    puts "Default tokens count: User = #{user_tokens_count}, Guest = #{guest_tokens_count}"

    AiToken.find_each do |ai_token|
      if ai_token.user.present?
        ai_token.update(tokens_count: user_tokens_count)
      elsif ai_token.guest.present?
        ai_token.update(tokens_count: guest_tokens_count)
      else
        puts "Skipping AiToken ID #{ai_token.id} - no associated user or guest."
      end
    end

    puts "Tokens count reset successfully!"
  end
end
