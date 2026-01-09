module DaouCustom
  class DashboardStatsService
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def start_date
      @start_date ||= (params[:start_date].presence || (Date.today - 1.year).strftime('%Y-%m-%d')).to_date
    end

    def end_date
      @end_date ||= (params[:end_date].presence || Date.today.strftime('%Y-%m-%d')).to_date
    end

    def target_projects
      if params[:project_id].present?
        parent = Project.visible.find_by(id: params[:project_id])
        parent ? parent.children.visible.sorted : []
      else
        Project.visible.where(parent_id: nil).sorted
      end
    end

    def stats_for_project(project)
      scope = Issue.visible.where(project_id: project.self_and_descendants.pluck(:id))
      scope = scope.where("issues.created_on >= ?", start_date.beginning_of_day)
      scope = scope.where("issues.created_on <= ?", end_date.end_of_day)
      
      counts = scope.group(:status_id).count
      total = counts.values.sum

      {
        counts: counts,
        total: total,
        chart_data: prepare_chart_data(counts)
      }
    end

    # 자주 사용하는 상태 객체 캐싱
    def self.status_map
      @status_map ||= {
        new: IssueStatus.where(name: ['신규', 'New']).first,
        in_progress: IssueStatus.where(name: ['진행', 'In Progress']).first,
        closed: IssueStatus.where(name: ['완료', 'Closed']).first,
        on_hold: IssueStatus.where(name: ['보류', 'On Hold']).first
      }
    end

    def self.display_statuses
      [status_map[:new], status_map[:in_progress], status_map[:closed], status_map[:on_hold]]
    end

    private

    def prepare_chart_data(counts)
      labels = []
      data = []
      colors = []
      status_colors = { '신규' => '#4A90E2', '진행' => '#4CAF50', '완료' => '#7F7F7F', '보류' => '#FF9800' }

      IssueStatus.sorted.each_with_index do |status, index|
        count = counts[status.id] || 0
        next if count == 0

        labels << "#{status.name} (#{count})"
        data << count
        colors << (status_colors[status.name] || "hsl(#{index * 137.5 % 360}, 70%, 60%)")
      end

      { labels: labels, data: data, colors: colors }
    end
  end
end
