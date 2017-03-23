#!/usr/bin/env ruby

require 'mspec/version'
require 'mspec/utils/options'
require 'mspec/utils/script'
require 'mspec/helpers/tmp'
require 'mspec/runner/actions/filter'
require 'mspec/runner/actions/timer'


class MSpecMain < MSpecScript
  def initialize
    config[:includes] = []
    config[:requires] = []
    config[:target]   = ENV['RUBY'] || 'ruby'
    config[:flags]    = []
    config[:command]  = nil
    config[:options]  = []
    config[:launch]   = []
  end

  def options(argv=ARGV)
    config[:command] = argv.shift if ["ci", "run", "tag"].include?(argv[0])

    options = MSpecOptions.new "mspec [COMMAND] [options] (FILE|DIRECTORY|GLOB)+", 30, config

    options.doc " The mspec command sets up and invokes the sub-commands"
    options.doc " (see below) to enable, for instance, running the specs"
    options.doc " with different implementations like ruby, jruby, rbx, etc.\n"

    options.configure do |f|
      load f
      config[:options] << '-B' << f
    end

    options.targets

    options.on("--warnings", "Don't supress warnings") do
      config[:flags] << '-w'
      ENV['OUTPUT_WARNINGS'] = '1'
    end

    options.on("-j", "--multi", "Run multiple (possibly parallel) subprocesses") do
      config[:multi] = true
      config[:options] << "-fy"
    end

    options.version MSpec::VERSION do
      if config[:command]
        config[:options] << "-v"
      else
        puts "#{File.basename $0} #{MSpec::VERSION}"
        exit
      end
    end

    options.help do
      if config[:command]
        config[:options] << "-h"
      else
        puts options
        exit 1
      end
    end

    options.doc "\n Custom options"
    custom_options options

    # The rest of the help output
    options.doc "\n where COMMAND is one of:\n"
    options.doc "   run - Run the specified specs (default)"
    options.doc "   ci  - Run the known good specs"
    options.doc "   tag - Add or remove tags\n"
    options.doc " mspec COMMAND -h for more options\n"
    options.doc "   example: $ mspec run -h\n"

    options.on_extra { |o| config[:options] << o }
    config[:options].concat options.parse(argv)
  end

  def register; end

  def report(files, timer)
    require 'yaml'

    exceptions = []
    tally = Tally.new

    files.each do |file|
      d = File.open(file, "r") { |f| YAML.load f }
      File.delete file

      exceptions += Array(d['exceptions'])
      tally.files!        d['files']
      tally.examples!     d['examples']
      tally.expectations! d['expectations']
      tally.errors!       d['errors']
      tally.failures!     d['failures']
    end

    require 'mspec/runner/formatters/multi'
    MultiFormatter.new(timer, tally, exceptions).finish
  end

  def multi_exec(argv)
    timer = TimerAction.new
    timer.start

    output_files = []
    i = 0
    pids = config[:ci_files].map { |specs|
      i += 1
      name = tmp "mspec-multi-#{i}"
      output_files << name

      env = { "SPEC_TEMP_DIR" => "rubyspec_temp_#{i+1}" }
      command = [config[:target]] + argv + ["-o", name, specs]
      $stderr.puts "$ #{command.join(' ')}"
      Process.spawn(env, *command)
    }

    pids.each { |pid|
      Process.wait(pid)
    }
    timer.finish
    report output_files, timer
  end

  def run
    argv = []

    argv.concat config[:launch]
    argv.concat config[:flags]
    argv.concat config[:includes]
    argv.concat config[:requires]
    argv << "-v"
    argv << "#{MSPEC_HOME}/bin/mspec-#{ config[:command] || "run" }"
    argv.concat config[:options]

    if config[:multi]
      multi_exec argv
    else
      cmd, *rest = config[:target].split(/\s+/)
      argv = rest + argv unless rest.empty?
      $stderr.puts "$ #{cmd} #{argv.join(' ')}"
      exec cmd, *argv
    end
  end
end
