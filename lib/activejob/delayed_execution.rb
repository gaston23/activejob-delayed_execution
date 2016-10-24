require 'activejob/delayed_execution/version'

module ActiveJob
  module DelayedExecution
    autoload :DelayedExecutionJob, 'activejob/delayed_execution/delayed_execution_job'

    class Proxy < BasicObject
      def initialize(object)
        @object = object
        @_set = nil
      end
      
      def set(*args)
        @_set = args
      end

      def method_missing(name, *args)
        DelayedExecutionJob.tap{ |job|
          job = job.set(*@_set) if @_set.present?
          job.perform_later(@object, name.to_s, *args)
        }
      end
    end

    private_constant :Proxy

    def delayed
      Proxy.new(self)
    end
  end
end
