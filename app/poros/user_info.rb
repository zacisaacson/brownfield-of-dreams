class UserInfo
  attr_reader :user

  def initialize(user)
    @user = user
    @token = user.github_token
  end

  def github_repos
    service = GithubService.new(@token)
    @github_repos ||= service.repos_by_user.take(5).map do |repo|
      Repo.new(repo)
    end
  end

  def github_followings
    service = GithubService.new(@token)
    @github_followings ||= service.followings_by_user.map do |following|
      Following.new(following)
    end
  end

  def github_followers
    service = GithubService.new(@token)
    @github_followers ||= service.followers_by_user.map do |follower|
      Follower.new(follower)
    end
  end

  def account?(follower)
    User.where('handle = ?', follower.login).exists?
  end

  def github_invitee(handle)
    service = GithubService.new(@token)
    @github_invitee ||= service.invitee_of_user(handle)
    Invitee.new(@github_invitee)
  end

  def sorted_videos
    grouped_videos = @user.videos.group_by(&:tutorial)

    grouped_videos.each do |_group_id, tutorial_id|
      tutorial_id.sort_by(&:position)
    end
  end
end
