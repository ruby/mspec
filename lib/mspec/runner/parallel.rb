class ParallelRunner
  def initialize(files, processes, formatter, argv)
    @files = files
    @processes = processes
    @formatter = formatter
    @argv = argv
    @last_files = {}
    @output_files = []
    @success = true
  end

  def launch_children
    @children = @processes.times.map { |i|
      name = tmp "mspec-multi-#{i}"
      @output_files << name

      env = {
        "SPEC_TEMP_DIR" => "rubyspec_temp_#{i}",
        "MSPEC_MULTI" => i.to_s
      }
      command = @argv + ["-fy", "-o", name]
      $stderr.puts "$ #{command.join(' ')}" if $MSPEC_DEBUG
      IO.popen([env, *command, close_others: false], "rb+")
    }
  end

  def handle(child, message)
    case message
    when '.'
      @formatter.unload
      send_new_file_or_quit(child)
    when nil
      raise "Worker died!"
    else
      while chunk = (io.read_nonblock(4096) rescue nil)
        message += chunk
      end
      message.chomp!('.')
      msg = "A child mspec-run process printed unexpected output on STDOUT"
      if last_file = @last_files[child]
        msg += " while running #{last_file}"
      end
      abort "\n#{msg}: #{message.inspect}"
    end
  end

  def send_new_file_or_quit(child)
    if @files.empty?
      child.puts "QUIT"
      _pid, status = Process.wait2(child.pid)
      @success &&= status.success?
      child.close
      @children.delete(child)
    else
      file = @files.shift
      @last_files[child] = file
      child.puts file
    end
  end

  def run
    MSpec.register_files @files
    launch_children

    puts @children.map { |child| child.gets }.uniq
    @formatter.start
    @children.each { |child| send_new_file_or_quit(child) }

    until @children.empty?
      IO.select(@children)[0].each { |child|
        handle(child, child.read(1))
      }
    end

    @formatter.aggregate_results(@output_files)
    @formatter.finish

    @success
  end
end
