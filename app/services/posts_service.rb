class PostsService
  def initialize(subject_title, problem_title, idea_title, post_type, subject_id, problem_id, post_id)
    @subject_title = subject_title
    @problem_title = problem_title
    @idea_title = idea_title
    @post_type = post_type
    @subject_id = subject_id
    @problem_id = problem_id
    @post_id = post_id
  end

  attr_accessor :subject_title, :problem_title, :idea_title, :post_type, :subject_id, :problem_id, :post_id

  def new_post
    result = {}

    if idea_title.present? && problem_title.present? && subject_title.present?
      subject_post = search_post(subject_title, Post::POST_TYPE_SUBJECT).last
      problem_post = search_post(problem_title, Post::POST_TYPE_PROBLEM).last
      result[:subject_id] = subject_post&.id
      result[:problem_id] = problem_post&.id
      result[:post] = Post.new(post_type: Post::POST_TYPE_IDEA, title: idea_title, subject_id: subject_post&.id, problem_id: problem_post&.id)
    elsif problem_title.present? && subject_title.present? && idea_title.blank?
      subject_post = search_post(subject_title, Post::POST_TYPE_SUBJECT).last
      result[:subject_id] = subject_post&.id
      result[:post] = Post.new(post_type: Post::POST_TYPE_PROBLEM, title: problem_title, subject_id: subject_post&.id)
    elsif subject_title.present? && problem_title.blank? && idea_title.blank?
      result[:post] = Post.new(post_type: Post::POST_TYPE_SUBJECT, title: subject_title)
    elsif subject_title.blank? && problem_title.present? && idea_title.blank?
      result[:subject_id] = nil
      result[:problem_id] = nil
      result[:post] = Post.new(post_type: Post::POST_TYPE_PROBLEM, title: problem_title)
    else
      result[:post] = Post.new(post_type: post_type)
      result[:subject_id] = subject_id
      result[:problem_id] = problem_id
      result[:post_id] = post_id
    end
    result
  end

  def search_post(title, post_type)
    ransack_fields = { title_cont: title, post_type: post_type }
    q = Post.ransack(ransack_fields)

    q.result(distinct: true).where(post_type: post_type)
  end
end