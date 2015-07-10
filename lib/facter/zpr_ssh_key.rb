Facter.add(:zpr_ssh_pubkey) do

  require 'etc'

  setcode do
    if system 'id -u zpr_proxy 2> /dev/null'
      if Etc.getpwnam('zpr_proxy')
        homedir = Etc.getpwnam('zpr_proxy')['dir']
        zpr_ssh_pubkey_file = "#{homedir}/.ssh/id_rsa.pub"
          File.read(zpr_ssh_pubkey_file).split()[1] if File.exists?(zpr_ssh_pubkey_file)
      end
    end
  end
end
