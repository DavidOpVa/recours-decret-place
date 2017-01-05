#!/bin/bash

. $(dirname $0)/config.inc

state=$(curl -s https://sagace.conseil-etat.fr/AuthentifierUtilisateur/AuthentifierUtilisateur.aspx | grep __VIEWSTATE | sed 's/.*value="//' | sed 's/".*//')
stateencode=$(echo "<?php echo urlencode('$state'); " | php );

state=$(curl -s -c /tmp/cookie.$$.txt -X POST -H 'Host: sagace.conseil-etat.fr' -H 'Referer: https://sagace.conseil-etat.fr/AuthentifierUtilisateur/AuthentifierUtilisateur.aspx' -H 'Content-Type: application/x-www-form-urlencoded' --data '__VIEWSTATE='$stateencode'&txtIdentifiant='$sagace_user'&txtPassword='$sagace_pass https://sagace.conseil-etat.fr/AuthentifierUtilisateur/AuthentifierUtilisateur.aspx  | grep __VIEWSTATE | sed 's/.*value="//' | sed 's/".*//')
stateencode=$(echo "<?php echo urlencode('$state'); " | php );

curl -s -b /tmp/cookie.$$.txt -X POST -H 'Host: sagace.conseil-etat.fr' -H 'Referer: https://sagace.conseil-etat.fr/AuthentifierUtilisateur/AuthentifierUtilisateur.aspx' -H 'Content-Type: application/x-www-form-urlencoded' --data '__VIEWSTATE='$stateencode https://sagace.conseil-etat.fr/Accueil/AccueilInfo.aspx | tr '\r' ' ' | sed 's/  */ /g' | recode iso88591..utf8 > /tmp/sagace.$$.html

echo '<?xml version="1.0" encoding="UTF-8"?><rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:wfw="http://wellformedweb.org/CommentAPI/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:sy="http://purl.org/rss/1.0/modules/syndication/"  xmlns:slash="http://purl.org/rss/1.0/modules/slash/">'
echo "<channel>"
echo "<title>"
grep -A 100 divCartNumDossier /tmp/sagace.$$.html | grep -B 100 divCartAffectation | sed 's/<[^>]*>//g' | tr '\n' ' '
echo "</title>"
echo "<description>"
grep -B 500 'id="divOnglet3"' /tmp/sagace.$$.html | grep -A 200 divAnalyse   | tr '\n' ' ' | sed 's|</tr>|</tr>\n|g' | sed 's/<[^>]*>/ /g'  | sed 's/&nbsp;/ /g' 
echo " (Generated by $0)"
echo "</description>"
echo "<link>https://sagace.conseil-etat.fr/Accueil/AccueilInfo.aspx</link>"
grep -A 500 tHistorique /tmp/sagace.$$.html  | grep 'td align="Center"' | sed 's/<[^>]*>/ /g' | sed 's/&nbsp;/ /g' | sed 's/^[^0-9]*//' | while read title ; do
echo "<item>"
date=$(echo $title | sed 's|\([0-9]*\)/\([0-9]*\)/\([0-9]*\) .*|\3-\2-\1|')
echo -n "<title>"
echo -n $title | sed 's/^[0-9\/]* *//'
echo "</title>"
echo -n "<pubDate>"
LANG=C date -R --date $date
echo "</pubDate>"
echo -n "<guid isPermaLink='false'>https://sagace.conseil-etat.fr/Accueil/AccueilInfo.aspx#"
echo $title $date | md5sum | sed 's/ .*//' 
echo "</guid>"
echo "<link>https://sagace.conseil-etat.fr/Accueil/AccueilInfo.aspx#"$date"</link>"
echo "</item>"
done ;
echo "</channel>"
echo "</rss>"
rm /tmp/cookie.$$.txt #/tmp/sagace.$$.html
