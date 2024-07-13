json.array!(@subjects.map) do |formatted_subject|
  json.subject do
    json.partial! 'json_attributes', locals: { post: formatted_subject }

    json.problems formatted_subject.child_posts.problem_posts do |problem|
      json.problem do
        json.partial! 'json_attributes', locals: { post: problem }

        json.ideas problem.ideas do |idea|
          json.idea do
            json.partial! 'json_attributes', locals: { post: idea }
          end
        end
      end
    end
  end
end
