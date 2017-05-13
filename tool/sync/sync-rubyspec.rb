IMPLS = {
  truffleruby: {
    git: "https://github.com/graalvm/truffleruby.git",
    from_commit: "f10ab6988d",
  },
  jruby: {
    git: "https://github.com/jruby/jruby.git",
    from_commit: "f10ab6988d",
  },
  rbx: {
    git: "https://github.com/rubinius/rubinius.git",
  },
  mri: {
    git: "https://github.com/ruby/ruby.git",
    master: "trunk",
    prefix: "spec/rubyspec",
  },
}

# Assuming the rubyspec repo is a sibling of the mspec repo
RUBYSPEC_REPO = File.expand_path("../../../../rubyspec", __FILE__)
raise RUBYSPEC_REPO unless Dir.exist?(RUBYSPEC_REPO)

NOW = Time.now

def sh(*args)
  puts args.join(' ')
  system(*args)
  raise unless $?.success?
end

def branch?(name)
  branches = `git branch`.sub('*', '').lines.map(&:strip)
  branches.include?(name)
end

def update_repo(info)
  repo_name = File.basename(info[:git], ".git")

  unless File.directory? repo_name
    sh "git", "clone", info[:git]
  end

  Dir.chdir(repo_name) do
    puts Dir.pwd

    sh "git", "checkout", (info[:master] || "master")
    sh "git", "pull"
  end
end

def filter_commits(impl, info)
  repo_name = File.basename(info[:git], ".git")

  Dir.chdir(repo_name) do
    date = NOW.strftime("%F")
    branch = "specs-#{date}"

    unless branch?(branch)
      sh "git", "checkout", "-b", branch

      from_commit = info[:from_commit]
      from_commit = "#{from_commit}..." if from_commit
      prefix = info[:prefix] || "spec/ruby"
      sh "git", "filter-branch", "-f", "--subdirectory-filter", prefix, *from_commit

      sh "git", "push", "-f", RUBYSPEC_REPO, "#{branch}:#{impl}"
    end
  end
end

def rebase_commits(impl, info)
  Dir.chdir(RUBYSPEC_REPO) do
    sh "git", "checkout", "master"
    sh "git", "pull"

    rebased = "#{impl}-rebased"
    if branch?(rebased)
      puts "#{rebased} already exists, assuming it correct"
      sh "git", "checkout", rebased
    else
      sh "git", "branch", "-D", rebased if branch?(rebased)
      sh "git", "checkout", "-b", rebased, impl.to_s

      last_merge = `git log --grep='Merge ruby/spec commit' -n 1 --format='%H %ct'`
      last_merge, commit_timestamp = last_merge.chomp.split(' ')

      raise "Could not find last merge" unless last_merge
      puts "Last merge is #{last_merge}"

      commit_date = Time.at(Integer(commit_timestamp))
      days_since_last_merge = (NOW-commit_date) / 86400
      if days_since_last_merge > 60
        raise "#{days_since_last_merge} since last merge, probably wrong commit"
      end

      puts "Rebasing..."
      sh "git", "rebase", "--onto", "master", last_merge
    end
  end
end

def test_new_specs
  require "yaml"
  Dir.chdir(RUBYSPEC_REPO) do
    versions = YAML.load_file(".travis.yml")
    versions = versions["matrix"]["include"].map { |job| job["rvm"] }
    versions.delete "ruby-head"
    min_version, max_version = versions.minmax

    run_rubyspec = -> version {
      command = "chruby #{version} && ../mspec/bin/mspec -j"
      sh ENV["SHELL"], "-c", command
    }
    run_rubyspec[min_version]
    run_rubyspec[max_version]
    run_rubyspec["trunk"]
  end
end

def main(impls)
  impls.each_pair do |impl, info|
    update_repo(info)
    filter_commits(impl, info)
    rebase_commits(impl, info)
    test_new_specs
  end
end

if ARGV == ["all"]
  impls = IMPLS
else
  args = ARGV.map { |arg| arg.to_sym }
  raise ARGV.to_s unless (args - IMPLS.keys).empty?
  impls = IMPLS.select { |impl| args.include?(impl) }
end

main(impls)
