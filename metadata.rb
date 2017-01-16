name              'locustio'
maintainer        'Alain Lefebvre'
maintainer_email  'hartfordfive@gmail.com'
license           'Apache v2.0'
description       'Installs/Configures locust'
long_description  'Installs/Configures locust'
issues_url        'https://github.com/hartfordfive/chef-locust/issues'
source_url        'https://github.com/hartfordfive/chef-locust'
version           '1.0.2'

depends 'poise-python',   '~> 1.5.1'
depends 'apt',            '~> 2.6.1'
depends 'runit',          '~> 3.0.3'
depends 'aws',            '~> 3.3.3'
depends 'firewall',       '~> 2.5.2'
depends 'zeromq',         '~> 1.1.0'

