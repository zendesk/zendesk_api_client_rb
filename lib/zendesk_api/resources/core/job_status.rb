module ZendeskAPI
  class JobStatus < ReadResource
    self.resource_name = 'job_statuses'
    self.singular_resource_name = 'job_status'
  end
end
