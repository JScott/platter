require 'logger'
require 'fileutils'

def from_workspace(job, with_logger: Logger.new(STDOUT))
  path = workspace_path_for job
  with_logger.info "Working from '#{path}' for '#{job}'"
  FileUtils.mkdir_p path
  Dir.chdir path do
    yield
  end
end

def workspace_path_for(job_name)
  current_dir = File.expand_path File.dirname(__FILE__)
  "#{current_dir}/../workspaces/#{job_name}"
end

def work_on(path, with_logger: Logger.new(STDOUT))
  with_logger.info "Running '#{path}'..."
  # TODO: path.split(' ') to bypass the shell when we're not using env vars
  IO.popen(path) do |io|
    while line = io.gets
      with_logger.info line
    end
  end
  with_logger.info "Script done. (exit status: #{$?.exitstatus})"
end

def start_job(job_name, scripts, with_logger: Logger.new(STDOUT))
  from_workspace(job_name, with_logger: with_logger) do
    scripts.each do |command|
      work_on command, with_logger: with_logger
    end
  end
end
