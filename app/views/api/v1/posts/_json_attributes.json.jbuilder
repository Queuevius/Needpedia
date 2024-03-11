json.id post.id
json.post_type post.post_type
json.user_id post.user_id
json.title post.title
json.content strip_tags(post&.content&.body&.to_plain_text)&.gsub("\r\n", "")
json.subject_id post.subject_id
json.problem_id post.problem_id
json.created_at post.created_at
json.updated_at post.updated_at
json.post_id post.post_id
json.curated post.curated
