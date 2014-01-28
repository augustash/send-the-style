worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 60
preload_app true
