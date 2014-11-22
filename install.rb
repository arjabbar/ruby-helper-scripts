system "bundle install"
require 'colorize'

class RubyInfo
  class << self
    def executable
      `which ruby`
    end

    def hash_bang
      @ruby_hash_bang ||= "#!#{executable}"
    end
  end
end

def scripts
  Dir['scripts/*']
end

def scripts_without_hashbangs
  scripts.select do |script_file|
    File.readlines(script_file)
      .select{|line| line.start_with? '#!'}
      .empty?
  end
end

def using_zsh?
  ENV['SHELL'].include? 'zsh'
end

def shell_rc_file
  return '~/.zshrc' if using_zsh?
  '~/.bashrc'
end

current_user = ENV['USER']

scripts_without_hashbangs

scripts_without_hashbangs.each do |file|
  puts "Adding hash bang to #{file}".green
  lines = File.readlines file
  new_file_content = (["#{RubyInfo.hash_bang}\n"] + lines).join
  File.write file, new_file_content
end

scripts.each do |script|
  script_link_path = "/usr/local/bin/#{script.split('/').last}"
  system "sudo chmod +x #{script}"
  system "sudo chmod o-w #{script}"
  system "sudo ln -f #{File.join Dir.pwd, script} #{script_link_path}"
  system "sudo chown #{current_user}: #{script_link_path}"
  system "$SHELL #{shell_rc_file}"
end