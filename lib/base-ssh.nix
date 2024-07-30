{ ... }:

{
	config = {
		services.openssh.enable = true;
		users.users.root.openssh.authorizedKeys.keys = [
			"ssh-ed25519 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA keks@host"
		];
	};
}
