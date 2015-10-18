maintainer       "IDERA"
maintainer_email "support@idera.com"
license          "None"
description      "Installs/Configures Uptime Cloud Monitor RevealCloud monitoring service agent"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.8"

recipe "revealcloud::default", "Installs RevealCloud agent binary"

supports 'linux', ">= 2.6.9"

