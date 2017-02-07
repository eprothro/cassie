module Cassie
  module Support
    class ServerProcess

      attr_reader :pid

      # Scan the system for cassandra processes running
      # @return [Array<ServerProcess>] Running cassandra processes
      # @raise [RuntimeError] if scanning with +ps+ system calls fails.
      def self.all
        pids.map{|pid| new(pid)}
      end

      # Starts a cassandra server process. {#running?} will be true if it started correctly.
      def initialize(pid=nil)
        @pid = pid

        if pid
          @running = true
        else
          start_cassandra
        end
      end

      # @return [Boolean] If the cassandra server started correctly. See {#errors} if false.
      def running?
        !!@running
      end

      # Stops the cassandra server processes, synchronously.
      # @raise [RuntimeError] if the process could not be killed.
      def stop
        self.class.pids.each do|pid|
          Process.kill("TERM", pid)
          loop do
            sleep(0.1)
            begin
              Process.getpgid( pid )
            rescue Errno::ESRCH
              break
            end
          end
        end
      end

      def command
        details[:command]
      end

      # @return [Array<String>] The Cassandra output lines tagged with ERROR
      # @!parse attr_reader :errors
      def errors
        return [] unless command && command.output
        command.output.split("\n").grep(/ERROR/)
      end

      protected

      def self.pids
        ps = Cassie::Support::SystemCommand.new("ps", ["-awx"])
        ps.succeed
        cassandra_awx = ps.output.split("\n").grep(/cassandra/)
        cassandra_awx.map{ |p| p.split(' ').first.to_i }
      end

      def start_cassandra
        start_pids = self.class.pids
        cassandra = Cassie::Support::SystemCommand.new("cassandra")
        cassandra.run
        new_pids = self.class.pids - start_pids
        Cassie.logger.warn "[WARN] - Multiple cassandra processes started, using first one." if new_pids.length > 1

        @running = !!(cassandra.output =~ /state jump to NORMAL/)
        @pid = new_pids.first
      end

      def details
        @details ||= fetch_details
      end

      def fetch_details
        # http://linuxcommand.org/man_pages/ps1.html (key long descriptions)
        # virtual memory size of the process in KiB
        # ps -p 62027 -o pid,user,ltime,vsize,pcpu,args -ww
        # PID USER     TIME      VSZ  %CPU ARGS
        # 62027 eprothro   44:24  6201356   1.0 /Library/Java/Java
        ps = Cassie::Support::SystemCommand.new("ps", ["-p", pid, "-o", "pid,user,etime,vsize,pcpu,args", "-ww"])
        ps.succeed
        puts ps.output
        elements = ps.output.split("\n")[1]
        elements = elements.split(" ")
        raise "Error fetching details, pid fetched doesn't match pid queried" unless elements.shift.to_i == self.pid

        {}.tap do |h|
          h[:user] = elements.shift
          offset = Time.now.getlocal.to_s.split(' ').last
          h[:started_at] = DateTime.parse("#{elements.shift} #{offset}")
          h[:memory] = elements.shift * 1024
          h[:cpu] = elements.shift / 100.0
        end
        #{p.split(' ').first.ljust(5,' ')} | #{p.split(' ').last}"
      end
    end
  end
end