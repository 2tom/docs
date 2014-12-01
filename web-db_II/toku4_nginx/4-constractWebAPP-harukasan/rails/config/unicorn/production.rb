worker_processes 8 # ワーカプロセス数
listen "/var/run/nginx-rails.sock" # ソケットファイル
pid    "/var/run/nginx-rails.pid"  # pidファイル

# 標準出力、標準エラーの出力先
stdout_path "./log/unicorn/production.log"
stderr_path "./log/unicorn/production.log"


#
# preload_appの設定
#
preload_app true
        
before_fork do |server, worker|
  # フォーク前にデータベースから切断する
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end

  sleep 1
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end

