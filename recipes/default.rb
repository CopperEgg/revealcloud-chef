#
# Cookbook Name:: revealcloud
# Recipe:: default
#
# Copyright 2012, CopperEgg
#
# Redistribution Encouraged
#

#
# Set node based on chef_environment, roles, node data in copperegg: tags[]
# {
#     "normal": {
#         "copperegg": {
#             "tags": ['tag1','tag2']
#          }
#     }
# }
#
tags = []

# If node.copperegg.tags_override exists regardless of value, then do _not_
# include the chef_environment and chef roles in the tag list
if( not ( node.attribute?("copperegg") and node.copperegg.attribute?("tags_override") ) )
    # If the tags_override flag is not set, then we will take the tags specified at the node
    # and add to them the chef_environment and the roles

    # Add the chef environment to the list
    tags.push(node.chef_environment)

    # Add any chef roles to the list
    node.roles.each do |role|
        tags.push(role)
    end
end

# Add the existing tags to the list
if (node.attribute?("copperegg") and node.copperegg.attribute?("tags") )
    if node.copperegg.tags != ""
      node.copperegg.tags.each do |tag|
          tags.push(tag)
      end
    end
end

# Create a comma seperated list of tags.
tag_list = tags.uniq.join(",")

log ("tag_list = " + tag_list)


#
# In piping the output of curl to sh, a SIGTERM error is sometimes encountered. To avoid this
# the curl statement is broken into consituent parts.
#
script "revealcloud_install" do
    interpreter "bash"
    cwd
    user "root"
    code <<-EOH
        curl http://#{node[:copperegg][:apikey]}@api.copperegg.com/chef.sh  > /tmp/revealcloud_installer.sh
        chmod +x /tmp/revealcloud_installer.sh
        export RC_TAG="#{tag_list}"
        export RC_LABEL="#{node[:copperegg][:label] || ''}"
        export RC_PROXY="#{node[:copperegg][:proxy] || ''}"
        export RC_OOM_PROTECT="#{node[:copperegg][:oom_protect] || ''}"
        export RC_UUID="#{node.fqdn || ''}"
        /tmp/revealcloud_installer.sh
    EOH
    not_if { ::File.exists?("/usr/local/revealcloud/run/revealcloud.pid") }
end


service "revealcloud" do
  supports :start => true, :stop => true, :restart => true
	action [:start] #starts the service if it's not running and enables it to start at system boot time
end


#
# Ubuntu Only
# Place the FQDN at the value of RC_UUID in .profile so that on long in, the node is recognized.
#
platform = node.platform

case node['platform']
    when "ubuntu"
        template "/home/revealcloud/.profile" do
            source      "revealcloud_profile.erb"
            owner       "revealcloud"
            group       "revealcloud"
            mode        "0644"
            variables(
                :RC_UUID => node.fqdn  # Use fully qualified domain name as UUID (revealcloud does the hashing)
            )
        end
    else
        log("Note, you are not installed RevealCloud to a Ubuntu plaform.  Your RC_UUID environment varliable
             is not getting set from the fqdn.") { level :warn }
end

