#
# Cookbook Name:: exabgp
# Resource:: exabgp_service
#
# Copyright 2012-2018, DNSimple Corp.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

provides :exabgp_service, os: 'linux' do |node|
  node['init_package'] == 'systemd'
end

property :bin_location, String, default: '/usr/sbin/exabgp'
property :install_name, String
property :config_name, String

action :create do
  control_service(:create)
end

action :enable do
  control_service(:enable)
end

action :start do
  control_service(:start)
end

action_class do
  include ExabgpCookbook::Helpers

  def control_service(service_action)
    edit_resource(:systemd_unit, "#{service_name}.service") do
      content(
        Unit: {
          Description: 'ExaBGP',
          Documentation: 'https://github.com/Exa-Networks/exabgp/wiki',
          After: 'network.target',
          ConditionPathExists: config_resource.config_path,
        },
        Service: {
          Environment: 'exabgp_daemon_daemonize=false',
          ExecStart: "#{install_resource.bin_path} #{config_resource.config_path}",
          ExecReload: '/bin/kill -USR1 $MAINPID',
          SuccessExitStatus: '0 1',
        },
        Install: {
          WantedBy: 'multi-user.target',
        }
      )
      verify false
      action service_action
    end
  end
end