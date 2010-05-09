#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use Test::Exception::LessClever;

BEGIN {
    use_ok( 'Exporter::Declare::Parser::Export' );
    use_ok( 'Exporter::Declare::Parser::Sublike' );
    use_ok( 'Exporter::Declare::Parser::Codeblock' );
    use_ok( 'Exporter::Declare::Parser::Method' );
    use_ok( 'Exporter::Declare::Parser::Begin' );
}

BEGIN {
    package MyExporter;
    use strict;
    use warnings;
    use Test::More;
    use Exporter::Declare;
    use Data::Dumper;

    export sl sublike {
        is( $name, 'a', "Got name" );
        pop(@_)->();
    }

    export cb codeblock {
        pop(@_)->();
    }

    export mth method {
        is( $name, 'a', "Got name" );
        pop(@_)->(1);
    }

    if ( eval { require Devel::BeginLift; 1 } ) {
        export beg begin {
            pop(@_)->();
        };
    }
}

BEGIN { MyExporter->import };

our %ran;

sl a {
    $ran{sl}++;
}

lives_and {
    if ( eval { require Devel::BeginLift; 1 } ) {
eval <<'EOT' || die( $@ );
        our $BEGIN;
        BEGIN { $BEGIN = 1 };
        $BEGIN = 0;
        ok( !$BEGIN, "reset begin" );
        beg( sub { $ran{beg}++; ok( $BEGIN, "In Begin" )});

        ok( $ran{beg}, "ran beg" );
EOT
    }
    else {
        diag "Skipping Devel::BeginLift tests";
    }
} "Devel::Begin";

cb {
    $ran{cd}++;
}

mth a {
    ok( $self, "got self" );
    $ran{mth}++;
}

ok( $ran{sl}, "ran sl" );
ok( $ran{cd}, "ran cd" );
ok( $ran{mth}, "ran mth" );

done_testing();
