Facter.add("zpr_ssh_pubkey") do

  setcode do
    zpr_ssh_pubkey_file = '/var/lib/zpr/.ssh/id_rsa.pub'
      File.read(zpr_ssh_pubkey_file).split()[1] if File.exists?(zpr_ssh_pubkey_file)
  end
end
