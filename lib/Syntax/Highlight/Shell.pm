package Syntax::Highlight::Shell;
use strict;
use Shell::Parser;

{ no strict;
  $VERSION = '0.01';
  @ISA = qw(Shell::Parser);
}

=head1 NAME

Syntax::Highlight::Shell - Highlight shell commands

=head1 VERSION

Version 0.01

=cut

my %classes = (
    metachar      => 's-mta',   # shell metacharacters (; |, >, &, \)
    keyword       => 's-key',   # a shell keyword (if, for, while, do...)
    builtin       => 's-blt',   # a builtin command
    command       => 's-cmd',   # an external command
    argument      => 's-arg',   # command arguments
    quote         => 's-quo',   # single (') and double (") quotes
    variable      => 's-var',   # an expanded variable ($VARIABLE)
    assigned      => 's-avr',   # an assigned variable (VARIABLE=value)
    value         => 's-val',   # a value
    comment       => 's-cmt',   # a comment
    line_number   => 's-lno',   # line number
);

my %defaults = (
    pre     => 1, # add <pre>...</pre> around the result? (default: yes)
    nnn     => 0, # add line numbers (default: no)
    syntax  => 'bourne', # shell syntax (default: Bourne shell)
    tabs    => 4, # convert tabs to this number of spaces; zero to disable
);

=head1 SYNOPSIS

    use Syntax::Highlight::Shell;

    my $highlighter = new Syntax::Highlight::Shell;
    $output = $highlighter->parse($shellcmd);

=head1 DESCRIPTION

This module is designed to take some text (assumed to be a shell command) 
and highlight it with meaningful colours. 

=head1 METHODS

=over 4

=item new()

The constructor. Returns a C<Syntax::Highlight::Shell> object. 

B<Options>

=over 4

=item *

C<nnn> - Activate line numbering. Default value: 0 (disabled). 

=item *

C<pre> - Surround result by C<< <pre>...</pre> >> tags. Default value: 1 (enabled). 

=item *

C<syntax> - Selects the shell syntax. Check L<Shell::Parser/"syntax"> for more 
information on the available syntaxes. Default value: C<bourne>. 

=item *

C<tabs> - When given a non-nul value, converts tabulations to this number of 
spaces. Default value: 4. 

=back

B<Example>

To avoid surrounding the result by the C<< <pre>...</pre> >> tags:

    my $highlighter = Syntax::Highlight::Shell->new(pre => 0);

=cut

sub new {
    my $self = __PACKAGE__->SUPER::new(handlers => {
        default => \&_generic_highlight
    });
    my $class = ref $_[0] || $_[0]; shift;
    bless $self, $class;
    
    $self->{_shs_options} = { %defaults };
    my %args = @_;
    for my $arg (keys %defaults) {
        $self->{_shs_options}{$arg} = $args{$arg} if $args{$arg}
    }
    
    $self->syntax($self->{_shs_options}{syntax});
    $self->{_shs_output} = '';
    
    return $self
}

=item parse()

Parse the shell code given in argument and returns the corresponding HTML 
code, ready for inclusion in a web page. 

B<Examples>

    $html = $highlighter->parse(q{ echo "hello world" });

    $html = $highlighter->parse(<<'END');
        # find my name
        if [ -f /etc/passwd ]; then
            grep $USER /etc/passwd | awk -F: '{print $5}' /etc/passwd
        fi
    END

=cut

sub parse {
    my $self = shift;
    
    ## parse the shell command
    $self->{_shs_output} = '';
    $self->SUPER::parse($_[0]);
    $self->eof;
    
    ## add line numbering?
    if($self->{_shs_options}{nnn}) {
        my $i = 1;
        $self->{_shs_output} =~ s|^|<span class="$classes{line_number}">@{[sprintf '%3d', $i++]}</span> |gm;
    }
    
    ## add <pre>...</pre>?
    $self->{_shs_output} = "<pre>\n" . $self->{_shs_output} . "</pre>\n" if $self->{_shs_options}{pre};
    
    ## convert tabs?
    $self->{_shs_output} =~ s/\t/' 'x$self->{_shs_options}{tabs}/ge if $self->{_shs_options}{tabs};
    
    return $self->{_shs_output}
}

=item _generic_highlight()

I<Internal method>

It's the C<Shell::Parser> callback that does all the work of highlighting 
the code. 

=cut

sub _generic_highlight {
    my $self = shift;
    my %args = @_;
    
    if(index('metachar,keyword,builtin,command,variable,comment', $args{type}) >= 0) {
        $self->{_shs_output} .= qq|<span class="$classes{$args{type}}">| 
                              . $args{token} . qq|</span>|
    
    } else {
        if($args{token} =~ /^(["'])([^"']*)\1$/) {
            $self->{_shs_output} .= qq|<span class="$classes{quote}">$1</span>|
                                  . qq|<span class="$classes{value}">$2</span>|
                                  . qq|<span class="$classes{quote}">$1</span>|
        
        } elsif($args{type} eq 'assign')  {
            $args{token} =~ s|^([^=]*)=|<span class="$classes{assigned}">$1</span>=<span class="$classes{value}">|;
            $args{token} =~ s|$|</span>|;
            $self->{_shs_output} .= $args{token}
        
        } else {
            $self->{_shs_output} .= $args{token}
        }
    }
}

=back

=head1 NOTES

The resulting HTML uses CSS to colourize the syntax. Here are the classes 
that you can define in your stylesheet. 

=over 4

=item *

C<.s-key> - for shell keywords (like C<if>, C<for>, C<while>, C<do>...)

=item *

C<.s-blt> - for the builtins commands

=item *

C<.s-cmd> - for the external commands

=item *

C<.s-arg> - for the command arguments

=item *

C<.s-mta> - for shell metacharacters (C<|>, C<< > >>, C<\>, C<&>)

=item *

C<.s-quo> - for the single (C<'>) and double (C<">) quotes

=item *

C<.s-var> - for expanded variables: C<$VARIABLE>

=item *

C<.s-avr> - for assigned variables: C<VARIABLE=value>

=item *

C<.s-val> - for shell values (inside quotes)

=item *

C<.s-cmt> - for shell comments

=back

An example stylesheet can be found in F<examples/shell-syntax.css>.

=head1 AUTHOR

Sébastien Aperghis-Tramoni, C<< <sebastien@aperghis.net> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-syntax-highlight-shell@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2004 Sébastien Aperghis-Tramoni, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Syntax::Highlight::Shell
