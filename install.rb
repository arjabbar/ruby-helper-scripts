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
      .select{|line| line.include? '#!'}
      .empty?
  end
end

scripts_without_hashbangs

scripts_without_hashbangs.each do |file|
  lines = File.readlines file
  File.writelines(file, [RubyInfo.hash_bang] + lines)
end