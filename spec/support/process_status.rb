def sample_ps_string
<<-EOS
  PID USER      ELAPSED      VSZ  %CPU ARGS
62027 eprothro 01:49:25  6203676   0.1 /Library/Java/JavaVirtualMachines/jdk1.8.0_72.jdk/Contents/Home/bin/java -Xloggc:/usr/local/cassandra/bin/../logs/gc.log -XX:+UseParNewGC -XX:+UseCon
EOS
end

def sample_pid
  62027
end