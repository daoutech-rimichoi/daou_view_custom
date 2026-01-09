class GitWebhookService
  def initialize(payload, controller)
    @payload = payload
    @controller = controller
  end

  def process_push
    changes = @payload['changes'] || []
    actor = @payload['actor']
    actor_email = actor&.dig('emailAddress')
    actor_name = actor&.dig('displayName') || actor&.dig('name')
    user = find_user_by_email(actor_email)
    
    project_name = @payload.dig('repository', 'project', 'name')
    repo_name = @payload.dig('repository', 'name')
    
    changes.each do |change|
      ref_id = change.dig('ref', 'displayId') || change['refId']
      from_hash = change['fromHash']
      to_hash = change['toHash']
      change_type = change['type']
      
      # Build commit URLs
      from_commit_url = build_commit_url(from_hash)
      to_commit_url = build_commit_url(to_hash)
      
      # Build notes using ERB
      notes = @controller.render_to_string(
        partial: 'git_webhooks/push_note',
        locals: {
          actor_name: actor_name,
          project_name: project_name,
          repo_name: repo_name,
          branch: ref_id,
          from_hash: from_hash,
          to_hash: to_hash,
          from_url: from_commit_url,
          to_url: to_commit_url
        }
      )
      
      # Try to extract issue_id from branch name or commit message
      issue_id = extract_issue_id(ref_id)
      
      GitHistory.create!(
        issue_id: issue_id,
        user_id: user&.id,
        notes: notes,
        created_on: Time.current
      )
      
      Rails.logger.info "Created git_history for push: #{change_type} on #{ref_id}" + (issue_id ? " (issue ##{issue_id})" : "")
    end
  end

  def process_pr(status)
    pr = @payload['pullRequest']
    return unless pr

    actor = @payload['actor']
    actor_email = actor&.dig('emailAddress')
    actor_name = actor&.dig('displayName') || actor&.dig('name')
    user = find_user_by_email(actor_email)

    pr_number = pr['id']
    title = pr['title']
    
    source_branch = pr.dig('fromRef', 'displayId')
    target_branch = pr.dig('toRef', 'displayId')
    project_name = pr.dig('fromRef', 'repository', 'project', 'name')
    repo_name = pr.dig('fromRef', 'repository', 'name')
    pr_url = build_pr_url(pr_number)
    
    # Extract issue_id
    issue_id = extract_issue_id(source_branch) || extract_issue_id(title)
    
    # Build notes using ERB
    notes = @controller.render_to_string(
      partial: 'git_webhooks/pr_note',
      locals: {
        status: status,
        actor_name: actor_name,
        project_name: project_name,
        repo_name: repo_name,
        from_branch: source_branch,
        to_branch: target_branch,
        title: title,
        pr_url: pr_url,
        pr_number: pr_number
      }
    )
    
    GitHistory.create!(
      issue_id: issue_id,
      user_id: user&.id,
      notes: notes,
      created_on: Time.current
    )
    
    Rails.logger.info "Created git_history for PR: ##{pr_number} (#{status})" + (issue_id ? " linked to issue ##{issue_id}" : "")
  end

  private

  def find_user_by_email(email)
    return nil unless email
    User.find_by_mail(email)
  end

  def extract_issue_id(text)
    return nil unless text
    
    # Extract from branch name (e.g., feature/issue-123-new-login)
    branch_match = text.match(/\/issue-(\d+)/i)
    return branch_match[1].to_i if branch_match
    
    # Extract from commit message or PR title (e.g., "refs #123", "fixes #123")
    # Matches common keywords: refs, fixes, closes, fix, close followed by # and number
    text_match = text.match(/(?:refs?|fixes?|closes?|fix|close)?\s*#(\d+)/i)
    text_match[1].to_i if text_match
  end

  def git_base_url
    @git_base_url ||= Setting.plugin_daou_custom['git_base_url']
  end

  def build_commit_url(revision)
    return nil unless revision && git_base_url.present?
    
    repo_slug = @payload.dig('repository', 'slug')
    project_key = @payload.dig('repository', 'project', 'key')
    
    return nil unless project_key && repo_slug
    
    "#{git_base_url}/projects/#{project_key}/repos/#{repo_slug}/commits/#{revision}"
  end

  def build_pr_url(pr_number)
    return nil unless pr_number && git_base_url.present?
    
    repo_slug = @payload.dig('pullRequest', 'fromRef', 'repository', 'slug')
    project_key = @payload.dig('pullRequest', 'fromRef', 'repository', 'project', 'key')
    
    return nil unless project_key && repo_slug
    
    "#{git_base_url}/projects/#{project_key}/repos/#{repo_slug}/pull-requests/#{pr_number}/overview"
  end
end
