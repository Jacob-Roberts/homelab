resource "tailscale_acl" "my_acl" {
  acl = <<EOF
  // Example/default ACLs for unrestricted connections.
{
	// Declare static groups of users. Use autogroups for all users or users with a specific role.
	// "groups": {
	//  	"group:example": ["alice@example.com", "bob@example.com"],
	// },

	// Define the tags which can be applied to devices and by which users.
	// tagged devices cannot use subnet router's routes
	"tagOwners": {
		"tag:ansible-robot":  ["autogroup:admin"],
		"tag:pbj":           ["autogroup:admin"],
		"tag:pbj-backup":    ["autogroup:admin"], // Backups are for the NUT devices
		"tag:slc1":           ["autogroup:admin"],
		"tag:slc1-backup":    ["autogroup:admin"], // Backups are for the NUT devices
		"tag:sgu1":           ["autogroup:admin"],
		"tag:pvu1":           ["autogroup:admin"],
		"tag:iad1":           ["autogroup:admin"],
		"tag:apple-tvs":      ["autogroup:admin"],
		"tag:vpn-exit-nodes": ["autogroup:admin"], // PiHoles will replace the Apple TVs
	},

	// Define access control lists for users, groups, autogroups, tags,
	// Tailscale IP addresses, and subnet ranges.
	"acls": [
		// I can access everything from my personal devices
		{
			"action": "accept",
			"src":    ["Jacob-Roberts@github", "jacob-roberts@passkey"],
			"dst":    ["*:*"],
		},
		// Allow all users and apple tvs to use any exit node
		{
			"action": "accept",
			"src": ["autogroup:member", "tag:apple-tvs"],
			"dst": ["autogroup:internet:*"],
		},
		// Ansible-robot needs access to all nodes
		{
			"action": "accept",
			"src":    ["tag:ansible-robot"],
			"dst":    ["*:*"],
		},
		// pbj-node-1 uses the apple TV's subnet route to access the nas in SLC (for backups)
		{
			"action": "accept",
			"src":    ["pbj-node-1"],
			"dst": [
				// pbj-node-1 needs to access IAD1 for the uptime kuma to work.
				"tag:iad1:*",
				// Get access to SLC1 Subnet
				"192.168.97.0/24:*",
			],
		},

		// iad1-node-1 needs to access pbj-node-1 and slc1-node-3 for the "cloudflare tunnel" to work
		{
			"action": "accept",
			"src":    ["iad1-node-1"],
			"dst": [
				"pbj-node-1:80",
				"pbj-node-1:443",
				"slc1-node-3:80",
				"slc1-node-3:443",
			],
		},

		// Proxmox needs access to slc1 for backups to work
		{
			"action": "accept",
			"src":    ["pbj-hv-1"],
			"dst": [
				"192.168.97.0/24:*",
			],
		},

		// Truenas needs to be able to see each other to do backup tasks
		{
			"action": "accept",
			"src":    ["truenas-slc1"],
			"dst":    ["truenas-pbj:*"],
		},
		{
			"action": "accept",
			"src":    ["truenas-pbj"],
			"dst":    ["truenas-slc1:*"],
		},
	],

	"hosts": {
		// special devices
		"pbj-node-1":         "100.81.118.52",
		"slc1-node-3":         "100.95.11.23",
		"iad1-node-1":         "100.109.65.68",
		"iad1-node-3":         "100.70.105.44",
		"pbj-hv-1": "100.87.7.24",
		"truenas-slc1":        "100.110.101.25",
		"truenas-pbj":        "100.85.14.53",
	},

	// Test access rules every time they're saved.
	// "tests": [
	//  	{
	//  		"src": "alice@example.com",
	//  		"accept": ["tag:example"],
	//  		"deny": ["100.101.102.103:443"],
	//  	},
	// ],
}
  EOF
}