require 'puppet/acceptance/install_utils'
extend Puppet::Acceptance::InstallUtils
require 'beaker/dsl/install_utils'
extend Beaker::DSL::InstallUtils

test_name "Install Packages"

step "Install repositories on target machines..." do

  sha = ENV['SHA']
  repo_configs_dir = 'repo-configs'

  hosts.each do |host|
    install_repos_on(host, 'puppet-agent', sha, repo_configs_dir)
  end
end

PACKAGES = {
  :redhat => [
    'puppet-agent',
  ],
  :debian => [
    'puppet-agent',
  ],
#  :solaris => [
#    'puppet',
#  ],
#  :windows => [
#    'puppet',
#  ],
}

install_packages_on(hosts, PACKAGES)

agents.each do |agent|
  case agent['platform']
  when /windows/
    arch = agent[:ruby_arch] || 'x86'
    base_url = ENV['MSI_BASE_URL'] || "http://builds.puppetlabs.lan/puppet-agent/#{ENV['SHA']}/artifacts/windows"
    filename = ENV['MSI_FILENAME'] || "puppet-agent-#{arch}.msi"

    install_puppet_from_msi(agent, :url => "#{base_url}/#{filename}")
  when /osx/
    opts = {
      :puppet_collection => 'PC1',
      :puppet_agent_sha => ENV['SHA'],
      :puppet_agent_version => ENV['SUITE_VERSION'] || ENV['SHA']
    }
    install_puppet_agent_dev_repo_on(agent, opts)
  end
end
