post "git/webhooks", to: "git_webhooks#receive"
post 'projects/:project_id/required_fields', to: 'project_required_fields#update', as: 'project_required_fields'