if (node.attribute?('ec2') && ! FileTest.directory?(node['zncrypt']['ec2_path']))

  service "ezencrypt" do
    action :stop
  end

  directory node['zncrypt']['ec2_path']

  %w{mount storage}.each do |dir|

    target_dir = ::File.join(node['zncrypt']['ec2_path'],::File.basename(node['zncrypt']["zncrypt_#{dir}"]))

    execute "migrate-zncrypt-#{dir}-directory" do
      command "mv #{node['zncrypt']["zncrypt_#{dir}"]} #{node['zncrypt']['ec2_path']}"
      not_if do FileTest.directory?(target_dir) end
    end

    mount node['zncrypt']["zncrypt_#{dir}"] do
      device target_dir
      fstype "none"
      options "bind,rw"
      action [:mount, :enable]
    end
  end

  service "ezencrypt" do
    action :start
  end

end