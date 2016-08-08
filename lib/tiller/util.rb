# Thanks, StackOverflow ;)
class ::Hash
  def deep_merge!(second)
    merger = proc { |_key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : [:undefined, nil, :nil].include?(v2) ? v1 : v2 }
    self.merge!(second, &merger)
  end
end

# This is needed so we can enumerate all the loaded plugins later
class Class
  def subclasses
    ObjectSpace.each_object(Class).select { |c| c < self }
  end
end

# Warn if values are being merged
def warn_merge(key, old, new, type, source)
  if (Tiller::config['warn_on_merge'])
    puts "Warning, merging duplicate #{type} values."
    puts "#{key} => '#{old}' being replaced by : '#{new}' from #{source}"
  end
  new
end

# Pass signals on to child process
def signal(sig, pid, options={})
  puts "Caught signal #{sig}, passing to PID #{pid}" if options[:verbose]
  begin
    Process.kill(sig, pid)
  rescue Errno::ESRCH
    false
  end
end

# Launch the replacement process.
def launch(cmd, _options={})
  # If an array, then we use a different form of spawn() which
  # avoids a subshell. See https://github.com/markround/tiller/issues/8
  if cmd.is_a?(Array)
    final='cmd[0]'
    # Build up the list of arguments when using the array form of spawn()
    if cmd.size > 1
      (1..cmd.size-1).each {|c| final="#{final} , cmd[#{c}]" }
    end
    pid=eval "spawn(#{final})"
  else
    pid=spawn(cmd)
  end

  pid
end