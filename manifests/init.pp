# Module: mercurial
#
class mercurial {

    package { 'mercurial':
        ensure => latest,
    }
}

define mercurial::clone (
    $source,
    $key = '~/.ssh/id_rsa',
    $ensure = 'tip' ) {

    include mercurial

    exec { "hg-clone-${name}":
        path    => '/bin:/usr/bin:/sbin:/usr/sbin',
        command => "hg clone -e 'ssh -i ${key}' -y -r ${ensure} ${source} ${name}",
        creates => $name,
        require => Package['mercurial'],
    }

    exec { "hg-pull-${name}":
        path    => '/bin:/usr/bin:/sbin:/usr/sbin',
        cwd     => $name,
        command => "hg -y pull  -e 'ssh -i ${key}' -u -r ${ensure}",
        onlyif  => $ensure ? {
            'tip'   => 'hg -y in',
            default => "test $(hg -y id  -e 'ssh -i ${key}' -i) != ${ensure}",
        },
        require => Exec["hg-clone-${name}"],
    }
}
