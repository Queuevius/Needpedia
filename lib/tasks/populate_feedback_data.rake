namespace :populate_feeback_data do
  desc "Populate questions and answers for feedback"
  task process: :environment do
    feedback = FeedbackQuestion.find_or_create_by(body: 'Has anything about Needpedia been hard to use or understand?')
    ['Not at all', 'A little', 'Very difficult'].each do |option|
      feedback.feedback_question_options.find_or_create_by(body: option)
    end
    feedback = FeedbackQuestion.find_or_create_by(body: 'How fast has the site been loading for you?')
    ['Fast', 'Normal', 'Slow'].each do |option|
      feedback.feedback_question_options.find_or_create_by(body: option)
    end
    feedback = FeedbackQuestion.find_or_create_by(body: 'How did you hear about Needpedia?')
    feedback = FeedbackQuestion.find_or_create_by(body: 'What would you like to see in the future?')
  end
end
