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

def sh(*args)
  puts args.join(' ')
  system(*args)
  raise unless $?.success?
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
    date = Time.now.strftime("%F")
    branch = "specs-#{date}"

    unless `git branch`.include?(branch)
      sh "git", "checkout", "-b", branch

      from_commit = info[:from_commit]
      from_commit = "#{from_commit}..." if from_commit
      prefix = info[:prefix] || "spec/ruby"
      sh "git", "filter-branch", "-f", "--subdirectory-filter", prefix, *from_commit

      sh "git", "push", "-f", RUBYSPEC_REPO, "#{branch}:#{impl}"
    end
  end
end

def main(impls)
  impls.each_pair do |impl, info|
    update_repo(info)
    filter_commits(impl, info)
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
