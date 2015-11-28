# Background job settings
class BackgroundJobSettings
  def self.pool_option
    { worker_interval: 4, restore_interval: 180,
      workers: { Job => 4, Recurr => 1 } }
  end
end
