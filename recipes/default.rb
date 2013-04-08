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
tmpfqdn = ''

# If node.copperegg.tags_override exists regardless of value, then do _not_
# include the chef_environment and chef roles in the tag list

if( node.attribute?("copperegg") )
    if( node.copperegg.attribute?("tags_override") == false )
      # Take the tags specified at the node and add to them the chef_environment and the roles

      # Add the chef environment to the list
      tags.push(node.chef_environment)

      # Add any chef roles to the list
      node.roles.each do |role|
        tags.push(role)
      end
    end
    if ( node.copperegg.attribute?('tags') )
      # Add the existing tags to the list
      if (node.copperegg.tags).kind_of?(Array)
        node.copperegg.tags.each do |tag|
          tags.push(tag)
        end
      end
    end
    if (node.copperegg.attribute?('use_fqdn') )
      if (node.copperegg.use_fqdn == true)
        log("Setting UUID to FQDN:\n")
        tmpfqdn = "#{node.fqdn || ''}"  
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
        export RC_UUID="#{tmpfqdn || ''}"
        /tmp/revealcloud_installer.sh
    EOH
    not_if { ::File.exists?("/usr/local/revealcloud/run/revealcloud.pid") }
end


service "revealcloud" do
  supports :start => true, :stop => true, :restart => true
	action [:start] #starts the service if it's not running and enables it to start at system boot time
end


