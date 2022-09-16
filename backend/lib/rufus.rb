require 'et-orbi'

Rufus::Scheduler::RepeatJob.class_eval do
  def first_at=(first)
    first_at = [first, EtOrbi.now].max
  end
end
