#!/bin/sh

echo "[+] Installing Perl Modules"
cpan -i LWP::UserAgen;
cpan -i HTTP::Request
cpan -i HTTP::Cookies
cpan -i HTTP::Response
cpan -i HTML::Entities
