Facter.add(:zpr_ssh_pubkey) do

  require 'etc'

  setcode do
    begin
      homedir = Etc.getpwnam('zpr_proxy')['dir']
      zpr_ssh_pubkey_file = "#{homedir}/.ssh/id_rsa.pub"
      File.read(zpr_ssh_pubkey_file).split()[1] if File.exists?(zpr_ssh_pubkey_file)
    rescue ArgumentError
    end
  end
end
