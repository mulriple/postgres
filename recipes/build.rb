#
# Cookbook Name:: postgres
# Recipe:: build
#
# Copyright 2012, Wanelo, Inc.
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


version     = node['postgres']['version']
prefix_dir  = node['postgres']['prefix_dir'].gsub(/%VERSION%/, version)
bin_dir     = prefix_dir + "/bin"

tarfile = "#{Chef::Config['file_cache_path']}/postgresql-#{version}.tar.gz"
src_dir = "#{Chef::Config['file_cache_path']}/postgresql-#{version}"

remote_file tarfile do
  source node['postgres']['remote_tar'].gsub('%VERSION%', version)
  mode 00644
  not_if { File.exist?(tarfile) }
end

bash "install postgres from source" do
  cwd Chef::Config['file_cache_path']
  code <<-EOH
    rm -rf #{src_dir}
    tar zxvf #{tarfile}
    cd #{src_dir}
    MAKEFLAGS="-j6" ./configure --prefix=#{prefix_dir} --with-template=solaris \
        --enable-nls --without-perl --without-python --without-readline \
        --without-tcl --without-zlib --enable-dtrace --with-openssl \
        --build=x86_64-sun-solaris2.11 --host=x86_64-sun-solaris2.11
    make
    make install
  EOH
  not_if "ls -1 #{bin_dir}/postgres"
end

include_recipe "postgres::contrib"

