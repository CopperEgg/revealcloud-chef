maintainer       "CopperEgg, Inc."
maintainer_email "support@copperegg.com"
license          "None"
description      "Installs/Configures CopperEgg RevealCloud monitoring service agent"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.8"

recipe "revealcloud::default", "Installs RevealCloud agent binary"

supports 'linux', ">= 2.6.9"

